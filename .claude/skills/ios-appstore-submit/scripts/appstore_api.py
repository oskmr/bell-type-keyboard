#!/usr/bin/env python3
"""App Store Connect API client for version creation, release notes, and review submission."""

import json
import sys
import time
import warnings

warnings.filterwarnings("ignore", category=DeprecationWarning)
warnings.filterwarnings("ignore", message=".*urllib3.*")

import jwt  # noqa: E402
import requests  # noqa: E402


def generate_jwt(key_id, issuer_id, key_path):
    with open(key_path, "r") as f:
        private_key = f.read()

    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "iat": now,
        "exp": now + 1200,
        "aud": "appstoreconnect-v1",
    }
    token = jwt.encode(payload, private_key, algorithm="ES256", headers={"kid": key_id})
    return token


def api_request(method, url, token, data=None):
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    resp = getattr(requests, method)(url, headers=headers, json=data)
    if resp.status_code >= 400:
        print(f"API ERROR ({resp.status_code}): {resp.text}", file=sys.stderr)
        sys.exit(1)
    if resp.status_code == 204:
        return None
    return resp.json()


BASE_URL = "https://api.appstoreconnect.apple.com/v1"


def get_app_id(token, bundle_id):
    """Bundle IDからApp IDを取得"""
    url = f"{BASE_URL}/apps?filter[bundleId]={bundle_id}"
    data = api_request("get", url, token)
    apps = data.get("data", [])
    if not apps:
        print(f"ERROR: Bundle ID '{bundle_id}' のアプリが見つかりません", file=sys.stderr)
        sys.exit(1)
    return apps[0]["id"]


def get_latest_version(token, app_id):
    """最新のApp Storeバージョンを取得"""
    url = (
        f"{BASE_URL}/apps/{app_id}/appStoreVersions"
        f"?filter[platform]=IOS"
    )
    data = api_request("get", url, token)
    versions = data.get("data", [])
    if not versions:
        return None

    def version_key(v):
        parts = v["attributes"]["versionString"].split(".")
        return tuple(int(p) for p in parts if p.isdigit())

    versions.sort(key=version_key, reverse=True)
    return versions[0]


def get_editable_version(token, app_id):
    """編集可能な（準備中/却下済みの）バージョンを取得"""
    url = (
        f"{BASE_URL}/apps/{app_id}/appStoreVersions"
        f"?filter[platform]=IOS"
        f"&filter[appStoreState]=PREPARE_FOR_SUBMISSION,DEVELOPER_REJECTED,REJECTED"
    )
    data = api_request("get", url, token)
    versions = data.get("data", [])
    if versions:
        return versions[0]
    return None


def create_version(token, app_id, version_string):
    """新しいApp Storeバージョンを作成"""
    url = f"{BASE_URL}/appStoreVersions"
    payload = {
        "data": {
            "type": "appStoreVersions",
            "attributes": {
                "versionString": version_string,
                "platform": "IOS",
                "releaseType": "MANUAL",
            },
            "relationships": {
                "app": {
                    "data": {"type": "apps", "id": app_id}
                }
            },
        }
    }
    data = api_request("post", url, token, payload)
    return data["data"]


def get_version_localizations(token, version_id):
    """バージョンのローカライゼーション一覧を取得"""
    url = f"{BASE_URL}/appStoreVersions/{version_id}/appStoreVersionLocalizations"
    data = api_request("get", url, token)
    return data.get("data", [])


def update_localization(token, localization_id, what_is_new):
    """ローカライゼーションのリリースノートを更新"""
    url = f"{BASE_URL}/appStoreVersionLocalizations/{localization_id}"
    payload = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "id": localization_id,
            "attributes": {
                "whatsNew": what_is_new,
            },
        }
    }
    api_request("patch", url, token, payload)


def create_localization(token, version_id, locale, what_is_new):
    """ローカライゼーションを新規作成"""
    url = f"{BASE_URL}/appStoreVersionLocalizations"
    payload = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "attributes": {
                "locale": locale,
                "whatsNew": what_is_new,
            },
            "relationships": {
                "appStoreVersion": {
                    "data": {"type": "appStoreVersions", "id": version_id}
                }
            },
        }
    }
    data = api_request("post", url, token, payload)
    return data["data"]


def get_builds(token, app_id, version_string=None):
    """アプリのビルド一覧を取得"""
    url = f"{BASE_URL}/builds?filter[app]={app_id}&sort=-uploadedDate&limit=5"
    if version_string:
        url += f"&filter[version]={version_string}"
    data = api_request("get", url, token)
    return data.get("data", [])


def select_build_for_version(token, version_id, build_id):
    """バージョンにビルドを紐付け"""
    url = f"{BASE_URL}/appStoreVersions/{version_id}/relationships/build"
    payload = {
        "data": {"type": "builds", "id": build_id}
    }
    api_request("patch", url, token, payload)


def get_or_create_review_submission(token, app_id):
    """既存のレビュー提出を取得、なければ新規作成"""
    url = f"{BASE_URL}/reviewSubmissions?filter[app]={app_id}&filter[platform]=IOS&filter[state]=READY_FOR_REVIEW,WAITING_FOR_REVIEW"
    data = api_request("get", url, token)
    submissions = data.get("data", [])

    for s in submissions:
        if s["attributes"]["state"] in ("READY_FOR_REVIEW", "WAITING_FOR_REVIEW"):
            return s

    url = f"{BASE_URL}/reviewSubmissions"
    payload = {
        "data": {
            "type": "reviewSubmissions",
            "attributes": {
                "platform": "IOS",
            },
            "relationships": {
                "app": {
                    "data": {"type": "apps", "id": app_id}
                }
            },
        }
    }
    data = api_request("post", url, token, payload)
    return data["data"]


def add_review_submission_item(token, submission_id, version_id):
    """レビュー提出にバージョンをアイテムとして追加"""
    url = f"{BASE_URL}/reviewSubmissionItems"
    payload = {
        "data": {
            "type": "reviewSubmissionItems",
            "relationships": {
                "reviewSubmission": {
                    "data": {"type": "reviewSubmissions", "id": submission_id}
                },
                "appStoreVersion": {
                    "data": {"type": "appStoreVersions", "id": version_id}
                },
            },
        }
    }
    data = api_request("post", url, token, payload)
    return data["data"]


def confirm_submission(token, submission_id):
    """審査提出を確定"""
    url = f"{BASE_URL}/reviewSubmissions/{submission_id}"
    payload = {
        "data": {
            "type": "reviewSubmissions",
            "id": submission_id,
            "attributes": {
                "submitted": True,
            },
        }
    }
    data = api_request("patch", url, token, payload)
    return data["data"]


def main():
    if len(sys.argv) < 2:
        print("Usage: appstore_api.py <command> [args...]", file=sys.stderr)
        print("Commands: get-app-id, create-version, set-release-notes, submit-review, full-submit", file=sys.stderr)
        sys.exit(1)

    command = sys.argv[1]

    key_id = sys.argv[2]
    issuer_id = sys.argv[3]
    key_path = sys.argv[4]

    token = generate_jwt(key_id, issuer_id, key_path)

    if command == "get-app-id":
        bundle_id = sys.argv[5]
        app_id = get_app_id(token, bundle_id)
        print(app_id)

    elif command == "create-version":
        app_id = sys.argv[5]
        version_string = sys.argv[6]

        existing = get_editable_version(token, app_id)
        if existing:
            existing_ver = existing["attributes"]["versionString"]
            if existing_ver == version_string:
                print(f"EXISTING:{existing['id']}")
                return
            else:
                print(f"INFO: 既存バージョン {existing_ver} を検出（新規 {version_string} を作成）", file=sys.stderr)

        version = create_version(token, app_id, version_string)
        print(f"CREATED:{version['id']}")

    elif command == "set-release-notes":
        version_id = sys.argv[5]
        release_notes = sys.argv[6]

        localizations = get_version_localizations(token, version_id)

        ja_loc = None
        for loc in localizations:
            if loc["attributes"]["locale"] == "ja":
                ja_loc = loc
                break

        if ja_loc:
            update_localization(token, ja_loc["id"], release_notes)
            print(f"UPDATED:ja:{ja_loc['id']}")
        else:
            new_loc = create_localization(token, version_id, "ja", release_notes)
            print(f"CREATED:ja:{new_loc['id']}")

        en_loc = None
        for loc in localizations:
            if loc["attributes"]["locale"].startswith("en"):
                en_loc = loc
                break
        if en_loc:
            update_localization(token, en_loc["id"], release_notes)
            print(f"UPDATED:en:{en_loc['id']}")

    elif command == "list-builds":
        app_id = sys.argv[5]
        version_string = sys.argv[6] if len(sys.argv) > 6 else None
        builds = get_builds(token, app_id, version_string)
        for b in builds:
            attrs = b["attributes"]
            state = attrs.get("processingState", "UNKNOWN")
            ver = attrs.get("version", "?")
            print(f"{b['id']}:{ver}:{state}")

    elif command == "set-encryption":
        build_id = sys.argv[5]
        uses_encryption = sys.argv[6].lower() == "true" if len(sys.argv) > 6 else False
        url = f"{BASE_URL}/builds/{build_id}"
        payload = {
            "data": {
                "type": "builds",
                "id": build_id,
                "attributes": {
                    "usesNonExemptEncryption": uses_encryption,
                },
            }
        }
        api_request("patch", url, token, payload)
        print(f"ENCRYPTION_SET:{build_id}:{uses_encryption}")

    elif command == "select-build":
        version_id = sys.argv[5]
        build_id = sys.argv[6]
        select_build_for_version(token, version_id, build_id)
        print(f"SELECTED:{build_id}")

    elif command == "submit-review":
        app_id = sys.argv[5]
        version_id = sys.argv[6]

        submission = get_or_create_review_submission(token, app_id)
        submission_id = submission["id"]
        print(f"SUBMISSION:{submission_id} (state: {submission['attributes']['state']})")

        item = add_review_submission_item(token, submission_id, version_id)
        print(f"ITEM_ADDED:{item['id']}")

        confirmed = confirm_submission(token, submission_id)
        print(f"SUBMITTED:{confirmed['id']} (state: {confirmed['attributes']['state']})")

    elif command == "update-version-string":
        version_id = sys.argv[5]
        new_version_string = sys.argv[6]
        url = f"{BASE_URL}/appStoreVersions/{version_id}"
        payload = {
            "data": {
                "type": "appStoreVersions",
                "id": version_id,
                "attributes": {
                    "versionString": new_version_string,
                },
            }
        }
        api_request("patch", url, token, payload)
        print(f"UPDATED:{version_id}:{new_version_string}")

    elif command == "delete-version":
        version_id = sys.argv[5]
        url = f"{BASE_URL}/appStoreVersions/{version_id}"
        api_request("delete", url, token)
        print(f"DELETED:{version_id}")

    elif command == "check-version-state":
        app_id = sys.argv[5]
        version = get_latest_version(token, app_id)
        if version:
            state = version["attributes"]["appStoreState"]
            ver = version["attributes"]["versionString"]
            print(f"{ver}:{state}:{version['id']}")
        else:
            print("NONE")

    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

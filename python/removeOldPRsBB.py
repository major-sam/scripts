import datetime

import requests as reqs
import json

# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.

headers = {'Content-Type': 'application/json; charset=utf-8',
           'Authorization': "Bearer Mjg2MDA1NDcxODY3OrNyl4l0+xUGJWi34wnpchTn11Mg",
           'X-Atlassian-Token': 'no-check'}

BB_ROOT = "https://bitbucket.baltbet.ru:8445"
BB_REST = "/rest/api/1.0/projects"


def get_prs(**kwargs):
    url = BB_ROOT + BB_REST + "/" + kwargs["project_key"] + "/repos/" + kwargs['repo_key'] + \
          "/pull-requests?limit=100&state=OPEN"
    print(url)
    result = reqs.get(
        url=url,
        headers=headers)

    content = result.json()
    old_pr_id = []
    for pr in content['values']:
        timestamp = pr['updatedDate']
        dt = datetime.datetime.utcfromtimestamp(timestamp / 1000)
        date_diff = datetime.datetime.now() - dt
        if date_diff.days > 30:
            old_pr_id.append({'id': str(pr['id']),
                              'version': pr['version']})
    return old_pr_id, content["isLastPage"]


def remove_prs(**kwargs):
    while True:
        old_pr_ids, is_last = get_prs(**kwargs)
        print(old_pr_ids)
        for pr_id in old_pr_ids:
            url = BB_ROOT + BB_REST + "/" + kwargs["project_key"] + "/repos/" + kwargs['repo_key'] + \
                  "/pull-requests/" + pr_id['id']
            print(url)
            payload = {'version': pr_id['version']}
            result = reqs.delete(
                url=url,
                headers=headers,
                data=json.dumps(payload)
            )
            print(result)
        if not old_pr_ids and is_last:
            break


if __name__ == '__main__':
    # TODO Переделать в консольный скрипт
    remove_prs(repo_key="server",
               project_key="BBP")

# See PyCharm help at https://www.jetbrains.com/help/pycharm/

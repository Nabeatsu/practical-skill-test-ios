FORMAT: 1A
 
# Group タスク
 
## タスク登録 [/tasks/{userId}.json]
 
### タスク登録API [POST]
 
#### 処理概要
 
* タスクの新規登録
* 登録に成功した場合、タスクのIDを返す。

+ Parameters
   + userId: 11440002 (number, required) - ユーザーの一意なID
 
+ Request (application/json)
 
    + Headers
 
            Accept: application/json
 
+ Response 200 (application/json)
 {
  "name": "LeLv0kJn1eEkHGX4p2t"
}

## タスク取得 [/tasks/{userId}.json]
### タスク一覧の読み込みAPI [GET]
 
#### 処理概要
 
* タスク一覧の読み込み
* 成功した場合、登録されたタスクの一覧を返す。
 
+ Parameters
   + userId: 11440002 (number, required) - ユーザーの一意なID
 
+ Request (application/json)
 
    + Headers
 
            Accept: application/json
 
+ Response 200 (application/json)
 
  {
  "taskId": {
    "title": "タスク名",
    "description": "メモ",
    "createdAt": "作成時間",
    "updatedAt": "最終更新時間"
  },
  "taskId2": {
    "title": "タスク名",
    "description": "メモ",
    "createdAt": "作成時間",
    "updatedAt": "最終更新時間"
  }
}




##タスクの変更 [/tasks/{userId}/{taskId}.json]

 
### タスク変更API [PATCH]
 
#### 処理概要
 
* タスクの変更
* 成功した場合、変更した情報と最終更新日を返す。

+ Parameters

   + userId: 11440002 (number, required) - ユーザーの一意なID
   + taskId: 300 (number, optional) - タスクに対して割り当てられた一意なID

 
+ Request (application/json)
 
    + Headers
 
            Accept: application/json
 
+ Response 200 (application/json)
 
    {
        "title": "タスク名",
        "description": "メモ",
        "updatedAt": "最終更新日"
    }

##タスクの削除 [/tasks/{userId}/{taskId}.json]

### タスク削除API [DELETE]
 
#### 処理概要
 
* タスクの削除
* 成功した場合、JSON nullを返す

+ Parameters

   + userId: 11440002 (number, required) - ユーザーの一意なID
   + taskId: 300 (number, optional) - タスクに対して割り当てられた一意なID
 
+ Request (application/json)
 
    + Headers
 
            Accept: application/json
 
+ Response 200 (application/json)

            null

from enum import Enum
import json

class ServerResponseType(Enum):
    LOGGED_IN = 0
    CHAT_MESSAGE = 1

class LoggedInResponse:
    MESSAGE_TYPE = ServerResponseType.LOGGED_IN
    def __init__(self, user_id, token, expires):
        self.user_id = user_id
        self.token = token
        self.expires = expires

    def toJSON(self):
        dictionary = {
            "user_id": self.user_id.__str__(),
            "token": self.token.__str__(),
            "expires": self.expires.__str__()
        }
        return json.dumps(dictionary, default=lambda o: o.__dict__, sort_keys=True, indent=None)

class ChatMessageResponse:
    MESSAGE_TYPE = ServerResponseType.CHAT_MESSAGE
    def __init__(self, chat_id, message_id, sender_name, body, date):
        self.chat_id = chat_id
        self.message_id = message_id
        self.sender_name = sender_name
        self.body = body
        self.date = date

    def toJSON(self):
        dictionary = {
            "chat_id": self.chat_id.__str__(),
            "message_id": self.message_id.__str__(),
            "sender_name": self.sender_name,
            "body": self.body,
            "date": self.date.__str__()
        }
        return json.dumps(dictionary, sort_keys=True, indent=None)

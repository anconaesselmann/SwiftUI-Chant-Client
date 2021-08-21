from enum import Enum
import json

class ServerResponseType(Enum):
    LOGGED_IN = 0
    CHAT_MESSAGE = 1
    TYPING_STATUS_UPDATE = 2

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

class TypingStatusUpdateResponse:
    MESSAGE_TYPE = ServerResponseType.TYPING_STATUS_UPDATE
    def __init__(self, is_typing, sender_name, chat_id, token):
        self.is_typing = is_typing
        self.sender_name = sender_name
        self.chat_id = chat_id

    def fromJSON(json_data):
        dictionary = json.loads(json_data.decode('utf-8'))
        return TypingStatusUpdateRequest(**dictionary)

    def toJSON(self):
        dictionary = {
            "is_typing": self.is_typing,
            "sender_name": self.sender_name,
            "chat_id": self.chat_id.__str__()
        }
        return json.dumps(dictionary, sort_keys=True, indent=None)

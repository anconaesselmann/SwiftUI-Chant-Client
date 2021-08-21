from enum import Enum
import json

class MessageType(Enum):
	NEW_USER = 0
	EMAIL_LOGIN = 1
	TOKEN_LOGIN = 2
	LOGGED_IN = 3
	CHAT_CLIENT = 4
	CHAT_SERVER = 5
	LOGGED_OUT = 6

class NewUserRequest:
	MESSAGE_TYPE = MessageType.NEW_USER
	def __init__(self, email, name, password):
		self.email = email
		self.name = name
		self.password = password

	def fromJSON(json_data):
		dictionary = json.loads(json_data.decode('utf-8'))
		return NewUserRequest(**dictionary)
		

	def toJSON(self):
		return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=None)


class EmailLoginRequest:
	MESSAGE_TYPE = MessageType.EMAIL_LOGIN
	def __init__(self, email, password):
		self.email = email
		self.password = password

	def fromJSON(json_data):
		dictionary = json.loads(json_data.decode('utf-8'))
		return EmailLoginRequest(**dictionary)

	def toJSON(self):
		return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=None)

class TokenLoginRequest:
	MESSAGE_TYPE = MessageType.TOKEN_LOGIN
	def __init__(self, user_id, token):
		self.user_id = user_id
		self.token = token

	def fromJSON(json_data):
		dictionary = json.loads(json_data.decode('utf-8'))
		return TokenLoginRequest(**dictionary)

	def toJSON(self):
		return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=None)

class LogoutRequest:
	MESSAGE_TYPE = MessageType.LOGGED_OUT
	def __init__(self, user_id, token):
		self.user_id = user_id
		self.token = token

	def fromJSON(json_data):
		dictionary = json.loads(json_data.decode('utf-8'))
		return TokenLoginRequest(**dictionary)

	def toJSON(self):
		return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=None)

class LoggedInResponse:
	MESSAGE_TYPE = MessageType.LOGGED_IN
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

class ChatMessageRequest:
	MESSAGE_TYPE = MessageType.CHAT_CLIENT
	def __init__(self, sender_id, chat_id, message_id, token, body):
		self.sender_id = sender_id
		self.chat_id = chat_id
		self.message_id = message_id
		self.token = token
		self.body = body

	def fromJSON(json_data):
		dictionary = json.loads(json_data.decode('utf-8'))
		return ChatMessageRequest(**dictionary)

	def toJSON(self):
		return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=None)

class ChatMessageResponse:
	MESSAGE_TYPE = MessageType.CHAT_SERVER
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

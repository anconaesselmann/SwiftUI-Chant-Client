from enum import Enum
import json

class ClientRequestType(Enum):
	SIGNUP = 0
	EMAIL_LOGIN = 1
	TOKEN_LOGIN = 2
	CHAT_MESSAGE = 3
	LOGGED_OUT = 4
	IS_TYPING = 5
	STOPPED_TYPING = 6
	MESSAGE_READ = 7

class NewUserRequest:
	MESSAGE_TYPE = ClientRequestType.SIGNUP
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
	MESSAGE_TYPE = ClientRequestType.EMAIL_LOGIN
	def __init__(self, email, password):
		self.email = email
		self.password = password

	def fromJSON(json_data):
		dictionary = json.loads(json_data.decode('utf-8'))
		return EmailLoginRequest(**dictionary)

	def toJSON(self):
		return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=None)

class TokenLoginRequest:
	MESSAGE_TYPE = ClientRequestType.TOKEN_LOGIN
	def __init__(self, user_id, token):
		self.user_id = user_id
		self.token = token

	def fromJSON(json_data):
		dictionary = json.loads(json_data.decode('utf-8'))
		return TokenLoginRequest(**dictionary)

	def toJSON(self):
		return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=None)

class LogoutRequest:
	MESSAGE_TYPE = ClientRequestType.LOGGED_OUT
	def __init__(self, user_id, token):
		self.user_id = user_id
		self.token = token

	def fromJSON(json_data):
		dictionary = json.loads(json_data.decode('utf-8'))
		return TokenLoginRequest(**dictionary)

	def toJSON(self):
		return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=None)

class ChatMessageRequest:
	MESSAGE_TYPE = ClientRequestType.CHAT_MESSAGE
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

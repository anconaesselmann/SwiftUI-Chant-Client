

from Auth import Authenticaton

from Messages import *
from MessageSerialization import serialize
# from MessageSerialization import read_from_stream

class Packet:
	def __init__(self, user_id, body):
		self.user_id = user_id
		self.body = body

	def toJSON(self):
		return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=None)

new_user_request = NewUserRequest(email = "axel.esselmann@gmail.com", name = "DudeOnRock", password = "Hannibal")


message_string = serialize(new_user_request)
print(message_string)

print(MessageType(0))


auth = Authenticaton()

token = auth.create_user(email = "axel.esselmann@gmail.com", name = "DudeOnRock", password = "Hannibal")

print("Token: " + token.token)
print(auth.create_user(email = "axel.esselmann@gmail.com", name = "DudeOnRock", password = "Hannibal"))

print("Validating")
print(auth.validate(token = token.token, user_id = token.user_id))
print(auth.log_out(user_id = token.user_id, token = token.token))
print(auth.validate(token = token.token, user_id = token.user_id))
print(auth.log_in(email = "axel.esselmann@gmail.com", password = "Hannibal2"))
print(auth.log_in(email = "axel.esselmann@gmail.com", password = "Hannibal"))



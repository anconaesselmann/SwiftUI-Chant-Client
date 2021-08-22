import uuid
from datetime import datetime, timedelta

class AuthToken:
	def __init__(self, user_id, token, expires: datetime):
		self.user_id = user_id
		self.token = token
		self.expires = expires

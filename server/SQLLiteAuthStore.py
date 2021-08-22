from __future__ import with_statement
from contextlib import closing
import sqlite3
import uuid
from AuthToken import *
import datetime

class SQLLiteAuthStore:
	def __init__(self, database_name):
		self.con = sqlite3.connect(database_name)
		self.con.execute("PRAGMA foreign_keys = 1")

		# self.hashes = {}
		# self.salts = {}
		# self.user_ids = {}
		# self.tokens = {}
		# self.names = {}

	def execute(self, query, values):
		with closing(self.con.cursor()) as cursor:
			cursor.execute(query, values)
			self.con.commit()

	def fetch_one(self, query, values):
		with closing(self.con.cursor()) as cursor:
			cursor.execute(query, values)
			return cursor.fetchone()
			# return cursor.fetchall()

	def fetch_uuid(self, query, values):
		result = self.fetch_one(query, values)
		if result is not None:
			return uuid.UUID(result[0])
		return None

	def store_hash(self, user_id, hash):
		query = """INSERT OR REPLACE INTO hashes (user_id, hash) VALUES (?, ?)"""
		values = (user_id.__str__(), hash)
		self.execute(query, values)

	def get_hash(self, user_id):
		query = """SELECT hash FROM hashes WHERE user_id=?"""
		values = (user_id.__str__(), )
		result = self.fetch_one(query, values)
		if result is not None:
			return result[0]
		return None

	def store_salt(self, user_id, salt):
		query = """INSERT OR REPLACE INTO salts (user_id, salt) VALUES (?, ?)"""
		values = (user_id.__str__(), salt)
		self.execute(query, values)

	def get_salt(self, user_id):
		query = """SELECT salt FROM salts WHERE user_id=?"""
		values = (user_id.__str__(), )
		result = self.fetch_one(query, values)
		if result is not None:
			return result[0]
		return None

	def store_token(self, token):
		token_string = token.token.__str__()
		user_id_string = token.user_id.__str__()
		expires = token.expires
		query = """INSERT OR REPLACE INTO tokens (user_id, token, expires) VALUES (?, ?, ?)"""
		values = (user_id_string, token_string, expires)
		self.execute(query, values)

	def get_token(self, user_id):
		query = """SELECT user_id, token, expires FROM tokens WHERE user_id=?"""
		values = (user_id.__str__(), )
		result = self.fetch_one(query, values)
		if not result:
			return None
		user_id, token, expires = result
		if isinstance(expires, str):
			expires = datetime.datetime.strptime(expires, "%Y-%m-%d %H:%M:%S.%f")
		token = AuthToken(user_id = uuid.UUID(user_id), token = token, expires = expires)
		print("Is string: ", isinstance(token.expires, str))
		return token

	def store_user(self, user_id, email, user_name):
		query = """INSERT INTO users (user_id, email, user_name) VALUES (?, ?, ?)"""
		values = (user_id.__str__(), email.strip().lower(), user_name)
		try:
			self.execute(query, values)
			return True
		except Exception as e:
			return False

	def delete_user(self, email):
		query = """DELETE FROM users WHERE email=?"""
		values = (email.strip().lower(), )
		self.execute(query, values)

	def delete_token(self, user_id):
		query = """DELETE FROM tokens WHERE user_id=?"""
		values = (user_id.__str__(), )
		self.execute(query, values)

	def get_user_id(self, email):
		query = """SELECT user_id FROM users WHERE email=?"""
		values = (email.strip().lower(), )
		return self.fetch_uuid(query = query, values = values)

	def get_user_name(self, user_id):
		query = """SELECT user_name FROM users WHERE user_id=?"""
		values = (user_id.__str__(), )
		result = self.fetch_one(query, values)
		if result is not None:
			return result[0]
		return None

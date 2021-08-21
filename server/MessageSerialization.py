import socket

HEADER_TYPE_LENGTH = 2
MEADER_MESSAGE_LENGTH = 10

def serialize(message):
	json_string = message.toJSON()
	type_header = str(message.__class__.MESSAGE_TYPE.value).rjust(HEADER_TYPE_LENGTH, " ")
	length_header = str(len(json_string)).rjust(MEADER_MESSAGE_LENGTH, " ")
	return type_header + length_header + json_string

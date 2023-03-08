typedef MSD = Map<String, dynamic>;

const PING_INTERVAL = Duration(seconds: 45);
const CONNECT_TIMEOUT = Duration(seconds: 30);
const MAX_FRAME_SIZE = 16384;
const UINT32_MAX = 0xFFFFFFFF;

abstract class WS {
  static const REQUEST_ERROR = "error";
  static const REQUEST_QUERIES = "q";
  static const REQUEST_TAG = "t";
  static const REQUEST_STATUS = "s";
  static const REQUEST_PATH = "p";
  static const REQUEST_NUMBER = "r";
  static const REQUEST_PAYLOAD = "b";
  static const REQUEST_COUNTERS = "c";
  static const REQUEST_DATA_PAYLOAD = "d";
  static const REQUEST_DATA_HASH = "h";
  static const REQUEST_COMPOUND_HASH = "ch";
  static const REQUEST_COMPOUND_HASH_PATHS = "ps";
  static const REQUEST_COMPOUND_HASH_HASHES = "hs";
  static const REQUEST_CREDENTIAL = "cred";
  static const REQUEST_APPCHECK_TOKEN = "token";
  static const REQUEST_AUTHVAR = "authvar";
  static const REQUEST_ACTION = "a";
  static const REQUEST_ACTION_STATS = "s";
  static const REQUEST_ACTION_QUERY = "q";
  static const REQUEST_ACTION_GET = "g";
  static const REQUEST_ACTION_PUT = "p";
  static const REQUEST_ACTION_MERGE = "m";
  static const REQUEST_ACTION_QUERY_UNLISTEN = "n";
  static const REQUEST_ACTION_ONDISCONNECT_PUT = "o";
  static const REQUEST_ACTION_ONDISCONNECT_MERGE = "om";
  static const REQUEST_ACTION_ONDISCONNECT_CANCEL = "oc";
  static const REQUEST_ACTION_AUTH = "auth";
  static const REQUEST_ACTION_APPCHECK = "appcheck";
  static const REQUEST_ACTION_GAUTH = "gauth";
  static const REQUEST_ACTION_UNAUTH = "unauth";
  static const REQUEST_ACTION_UNAPPCHECK = "unappcheck";
  static const RESPONSE_FOR_REQUEST = "b";
  static const SERVER_ASYNC_ACTION = "a";
  static const SERVER_ASYNC_PAYLOAD = "b";
  static const SERVER_ASYNC_DATA_UPDATE = "d";
  static const SERVER_ASYNC_DATA_MERGE = "m";
  static const SERVER_ASYNC_DATA_RANGE_MERGE = "rm";
  static const SERVER_ASYNC_AUTH_REVOKED = "ac";
  static const SERVER_ASYNC_APP_CHECK_REVOKED = "apc";
  static const SERVER_ASYNC_LISTEN_CANCELLED = "c";
  static const SERVER_ASYNC_SECURITY_DEBUG = "sd";
  static const SERVER_DATA_UPDATE_PATH = "p";
  static const SERVER_DATA_UPDATE_BODY = "d";
  static const SERVER_DATA_START_PATH = "s";
  static const SERVER_DATA_END_PATH = "e";
  static const SERVER_DATA_RANGE_MERGE = "m";
  static const SERVER_DATA_TAG = "t";
  static const SERVER_DATA_WARNINGS = "w";
  static const SERVER_RESPONSE_DATA = "d";
}

abstract class C {
  static const REQUEST_TYPE = "t";
  static const REQUEST_TYPE_DATA = "d";
  static const REQUEST_PAYLOAD = "d";
  static const SERVER_ENVELOPE_TYPE = "t";
  static const SERVER_DATA_MESSAGE = "d";
  static const SERVER_CONTROL_MESSAGE = "c";
  static const SERVER_ENVELOPE_DATA = "d";

  static const SERVER_CONTROL_MESSAGE_TYPE = "t";
  static const SERVER_CONTROL_MESSAGE_SHUTDOWN = "s";
  static const SERVER_CONTROL_MESSAGE_RESET = "r";
  static const SERVER_CONTROL_MESSAGE_HELLO = "h";
  static const SERVER_CONTROL_MESSAGE_DATA = "d";

  static const SERVER_HELLO_TIMESTAMP = "ts";
  static const SERVER_HELLO_HOST = "h";
  static const SERVER_HELLO_SESSION_ID = "s";

  static const LAST_SESSION_ID_PARAM = "ls";
}
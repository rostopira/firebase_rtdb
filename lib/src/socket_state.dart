enum SocketState implements Comparable<SocketState> {
  NEW,
  CONNECTING,
  CONNECTED,
  CLOSING,
  CLOSED;

  @override
  int compareTo(SocketState other) =>
      index.compareTo(other.index);

  bool operator <(SocketState b) => index < b.index;
  bool operator <=(SocketState b) => index <= b.index;
  bool operator >(SocketState b) => index > b.index;
  bool operator >=(SocketState b) => index >= b.index;
}
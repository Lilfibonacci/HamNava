abstract class UserEvent {}

class SearchUserEvent extends UserEvent {
  final String userName;

  SearchUserEvent(this.userName);
}

class AddFriendEvent extends UserEvent {
 final String userName;

  AddFriendEvent(this.userName);
}

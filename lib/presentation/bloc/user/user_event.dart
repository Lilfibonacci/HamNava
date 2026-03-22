abstract class UserEvent {}

class SearchUserEvent extends UserEvent {
 final String userName;

  SearchUserEvent(this.userName);
}

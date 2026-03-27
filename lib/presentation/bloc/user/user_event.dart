abstract class UserEvent {}

// ---------------- search user ----------------

class SearchUserEvent extends UserEvent {
  final String userName;

  SearchUserEvent(this.userName);
}

// ---------------- add friend ----------------

class AddFriendEvent extends UserEvent {
  final String userId;

  AddFriendEvent(this.userId);
}

// ---------------- friend List ----------------

class FriendListEvent extends UserEvent {
  final String userId;
  FriendListEvent(this.userId);
}

// ---------------- profile info ----------------

class ProfileInfoEvent extends UserEvent {
  final String userId;

  ProfileInfoEvent(this.userId);
}

// ---------------- update profile info ----------------

class UpdateProfileInfoEvent extends UserEvent {
  final String userId;
  final String userName;
  final String name;
  final String email;

  UpdateProfileInfoEvent(this.userId, this.userName, this.email, this.name);
}

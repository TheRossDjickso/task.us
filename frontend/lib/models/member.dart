class Member {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final bool isPending;
  final String role;

  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.isPending = false,
    this.role = 'read only',
  });

  Member copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isPending,
    String? role,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPending: isPending ?? this.isPending,
      role: role ?? this.role,
    );
  }
}

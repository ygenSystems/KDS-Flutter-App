class Department {
  final String name;
  Department.empty() : name = '';
  Department.fromMap({required Map<String, dynamic> map}) : name = map['name'];
}

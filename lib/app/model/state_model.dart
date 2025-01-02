class StateModel {
	int? id;
	String? arName;
	String? enName;
	dynamic createdAt;
	dynamic updatedAt;

	StateModel({
		this.id, 
		this.arName, 
		this.enName, 
		this.createdAt, 
		this.updatedAt, 
	});

	@override
	String toString() {
		return 'StateModel(id: $id, arName: $arName, enName: $enName, createdAt: $createdAt, updatedAt: $updatedAt)';
	}

	factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
				id: json['id'] as int?,
				arName: json['ar_name'] as String?,
				enName: json['en_name'] as String?,
				createdAt: json['created_at'] as dynamic,
				updatedAt: json['updated_at'] as dynamic,
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'ar_name': arName,
				'en_name': enName,
				'created_at': createdAt,
				'updated_at': updatedAt,
			};
}

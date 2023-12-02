class calcEntry { //model class that is used for modeling the calculation in the DB
  String date;
  int total;
  String items;
  int? id;
  calcEntry({ //basic constructor
    required this.date,
    required this.total,
    required this.items,
    this.id
  });

  Map<String, dynamic> toJson() { //function to convert class to json
    return {
      'date': date,
      'total': total,
      'items': items
    };
  }

  Map<String,dynamic> toMap() { //function to convert class to map
    return {
      'date': date,
      'total': total,
      'items': items
    };
  }
  factory calcEntry.fromJson(Map<String, dynamic> json) { //function to create class from json
    return calcEntry(date: json['date'], total: json['total'], items: json['items']);
  }
  
  factory calcEntry.fromMap(Map<String, dynamic> json){ //function to create class from map
    return calcEntry(date: json['date'], total: json['total'], items: json['items'], id: json['id']);
  }

  @override
  String toString() { //to string method, for when an class object is printed
    return "date: $date\ntotal: $total \nitems: $items";
  }



}

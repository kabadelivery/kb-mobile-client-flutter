


class CustomerCareChatMessageModel {

   int? id;
   String? message;
   int? created_at;
   bool? state = true; /* deleted or not */
   int? viewed;
   int? user_id;

   CustomerCareChatMessageModel({this.id, this.message, this.created_at,
     this.state, this.viewed, this.user_id});

   /* if 0, admin, else me. */


   CustomerCareChatMessageModel.fromJson(Map<String, dynamic> json) {

     id = json['id'];
     message = json['message'];
     created_at = json['created_at'];
     state = json['state'];
     viewed = json['viewed'];
     user_id = json['user_id'];
   }

   Map toJson () => {
     "id" : (id as int),
     "message" : message,
     "created_at" : created_at,
     "state" : state as int,
     "viewed" : viewed as int,
     "user_id" : user_id as int,
   };

   @override
   String toString() {
     return toJson().toString();
   }

}

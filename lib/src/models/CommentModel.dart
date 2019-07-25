


class CommentModel {

   int id;
   String content = "Here is the content of the famous comment we've been talking about the whole time...";
   double stars;
   String created_at = "153787738928"; // date
   String date_string = "153787738928"; // date
   String name_of_client = "Ruph Ruphinos"; // show it partially
   bool hidden = false;
   String pic;

   CommentModel(this.id, this.content, this.stars, this.created_at,
       this.date_string, this.name_of_client, this.hidden, this.pic);

   CommentModel.fromJson(Map<String, dynamic> json) {

      id = json['id'];
      content = json['content'];
      stars = json['stars'];
      created_at = json['created_at'];
      date_string = json['date_string'];
      name_of_client = json['name_of_client'];
      hidden = json['hidden'];
      pic = json['pic'];
   }

   Map toJson () => {
      "id" : (id as int),
      "content" : content,
      "stars" : stars,
      "created_at" : created_at,
      "date_string" : date_string,
      "name_of_client" : name_of_client,
      "hidden" : hidden,
      "pic" : pic,
   };

   @override
   String toString() {
      return toJson().toString();
   }

}
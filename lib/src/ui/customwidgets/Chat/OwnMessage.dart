import "package:flutter/material.dart" ;
class OwnMessageCard extends StatelessWidget{
  final String message ;
  const OwnMessageCard({  required this.message}) ;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(constraints:BoxConstraints(
        maxHeight:  MediaQuery.of(context).size.width-45 ,
      ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Color(0xffdcf8c6),
          margin: EdgeInsets.symmetric(horizontal: 15 ,vertical:5),
          child:Stack(
             children:[
               Padding(
                 padding: const EdgeInsets.only(left: 10 , right: 80 , top : 10 , bottom: 20),
                 child: Text(message,style:TextStyle(
                   fontSize:16,
                 )),
               ),
               Positioned(
                 bottom: 4,
                 right: 10,
                 child: Row(
                   children: [
                    Text("20:58",style:TextStyle(fontSize:13 , color:Colors.grey)),
                     SizedBox(width: 5,),
                     Icon(Icons.done_all,size: 20,),
                   ],
                 ),
               )
             ]
      
          )
        ),
      ),
    ) ;
  }}
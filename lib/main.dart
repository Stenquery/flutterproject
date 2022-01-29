import 'package:flutter/material.dart';

//hahahahah i am a software engineer
//There is to much way to walk 
//We are at just begining
void main() { //const MyApp()
  runApp(MaterialApp(
    home: MyApp()
  ));
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var liste = ["Ahmet","Mehmet","Muzaffer"];
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello mu World"),
      ),
      body:Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: liste.length,
            itemBuilder: (BuildContext context,int index){
              return Text(liste[index]);
            }),
        ),
         Center(
        child:ElevatedButton(
          child: Text("Sonucu Gör."),
          onPressed: (){
            var mark = 55;
            var message;
            if(mark<45){
              message ="Kaldınız sorumlu öğretmeninize uğrayınız.";
            }
            else if(mark>=45 && mark<50){
              message ="Bütünlemeye kaldınız biraz daha gayret.";
            }
            else{
              message="Tebrikler.Dersi başarıyla geçtiniz.";
            }
          var alert = AlertDialog(
            title: Text("Sınav Sonucu"),
          content: Text(message),
          );
          showDialog(context: context, builder: (BuildContext context)=>alert);
        }, 
        ),
      ) ,
      ],)
    );
  }

}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
      
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     return Scaffold(
//       appBar: AppBar(
        
//         title: Text(widget.title),
//       ),
//       body: Center(
        
//         child: Column(
      
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

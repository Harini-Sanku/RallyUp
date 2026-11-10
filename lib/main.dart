import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const RallyUpApp());

const ink = Color(0xFF101820);
const panel = Color(0xFF192630);
const lime = Color(0xFFC6F36B);
const muted = Color(0xFF9AA9B3);
const bg = Color(0xFF0D151B);

class RallyUpApp extends StatelessWidget {
  const RallyUpApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'RallyUp',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark, scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: lime, surface: panel),
      useMaterial3: true, fontFamily: 'Arial',
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: const Color(0xFF22313B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        hintStyle: const TextStyle(color: muted),
      ),
    ),
    home: const AppShell(),
  );
}

class MatchItem {
  String id, sport, title, venue, date, time, level, host;
  int players, capacity;
  double fee;
  MatchItem({required this.id, required this.sport, required this.title, required this.venue,
    required this.date, required this.time, required this.level, required this.host,
    required this.players, required this.capacity, required this.fee});
  Map<String,dynamic> toJson()=>{'id':id,'sport':sport,'title':title,'venue':venue,'date':date,
    'time':time,'level':level,'host':host,'players':players,'capacity':capacity,'fee':fee};
  factory MatchItem.fromJson(Map<String,dynamic> j)=>MatchItem(id:j['id'],sport:j['sport'],title:j['title'],
    venue:j['venue'],date:j['date'],time:j['time'],level:j['level'],host:j['host'],
    players:j['players'],capacity:j['capacity'],fee:(j['fee'] as num).toDouble());
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override State<AppShell> createState()=>_AppShellState();
}
class _AppShellState extends State<AppShell> {
  int tab=0;
  String selectedSport='All';
  List<MatchItem> matches=[
    MatchItem(id:'m1',sport:'Badminton',title:'Evening doubles rally',venue:'Smash Arena, Madhapur',date:'Today',time:'6:00 PM',level:'Intermediate',host:'Aarav',players:3,capacity:4,fee:180),
    MatchItem(id:'m2',sport:'Football',title:'5-a-side friendly',venue:'Turf Central, Gachibowli',date:'Today',time:'7:30 PM',level:'All levels',host:'Rohan',players:8,capacity:10,fee:150),
    MatchItem(id:'m3',sport:'Tennis',title:'Weekend singles',venue:'Ace Tennis Club',date:'Tomorrow',time:'7:00 AM',level:'Advanced',host:'Maya',players:1,capacity:2,fee:250),
    MatchItem(id:'m4',sport:'Cricket',title:'Box cricket night',venue:'Boundary Box, Kondapur',date:'Tomorrow',time:'8:00 PM',level:'Intermediate',host:'Kabir',players:9,capacity:12,fee:120),
    MatchItem(id:'m5',sport:'Pickleball',title:'Beginner friendly game',venue:'Court 9, Jubilee Hills',date:'Sat, 15 Nov',time:'5:00 PM',level:'Beginner',host:'Isha',players:2,capacity:4,fee:200),
  ];
  final joined=<String>{};
  final bookings=<String>[];
  final sports=['All','Badminton','Cricket','Football','Tennis','Basketball','Pickleball','Volleyball'];
  @override void initState(){super.initState(); _load();}
  Future<void> _load() async {
    final p=await SharedPreferences.getInstance();
    final raw=p.getString('matches');
    if(raw!=null){try{matches=(jsonDecode(raw) as List).map((e)=>MatchItem.fromJson(e)).toList();}catch(_){}}
    joined.addAll(p.getStringList('joined')??[]);
    bookings.addAll(p.getStringList('bookings')??[]);
    if(mounted)setState((){});
  }
  Future<void> _save() async {
    final p=await SharedPreferences.getInstance();
    await p.setString('matches',jsonEncode(matches.map((e)=>e.toJson()).toList()));
    await p.setStringList('joined',joined.toList());
    await p.setStringList('bookings',bookings);
  }
  void _join(MatchItem m){
    if(joined.contains(m.id)||m.players>=m.capacity)return;
    setState((){joined.add(m.id);m.players++;}); _save();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('You joined the match!')));
  }
  void _createMatch(){
    showDialog(context:context,builder:(ctx)=>CreateMatchDialog(onCreate:(m){
      setState(()=>matches.insert(0,m));_save();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Match created successfully')));
    }));
  }
  @override Widget build(BuildContext context){
    final pages=[
      _home(), _discover(), _bookings(), _leaderboard(), _profile()
    ];
    return LayoutBuilder(builder:(context,c){
      final wide=c.maxWidth>850;
      return Scaffold(
        body: Row(children:[
          if(wide) NavigationRail(backgroundColor:ink,selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),
            labelType:NavigationRailLabelType.all,selectedIconTheme:const IconThemeData(color:lime),
            unselectedIconTheme:const IconThemeData(color:muted),destinations:const [
              NavigationRailDestination(icon:Icon(Icons.grid_view_rounded),label:Text('Home')),
              NavigationRailDestination(icon:Icon(Icons.explore_outlined),label:Text('Discover')),
              NavigationRailDestination(icon:Icon(Icons.confirmation_num_outlined),label:Text('Bookings')),
              NavigationRailDestination(icon:Icon(Icons.emoji_events_outlined),label:Text('Rankings')),
              NavigationRailDestination(icon:Icon(Icons.person_outline),label:Text('Profile')),
            ]),
          Expanded(child:SafeArea(child:Column(children:[
            _topBar(),
            Expanded(child:IndexedStack(index:tab,children:pages)),
            if(!wide) NavigationBar(backgroundColor:ink,indicatorColor:lime.withOpacity(.15),
              selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),
              destinations:const [
                NavigationDestination(icon:Icon(Icons.grid_view_rounded),label:'Home'),
                NavigationDestination(icon:Icon(Icons.explore_outlined),label:'Discover'),
                NavigationDestination(icon:Icon(Icons.confirmation_num_outlined),label:'Bookings'),
                NavigationDestination(icon:Icon(Icons.emoji_events_outlined),label:'Ranks'),
                NavigationDestination(icon:Icon(Icons.person_outline),label:'Profile'),
              ]),
          ]))),
        ]),
        floatingActionButton:tab==0||tab==1?FloatingActionButton.extended(
          backgroundColor:lime,foregroundColor:ink,onPressed:_createMatch,
          icon:const Icon(Icons.add),label:const Text('Create match',style:TextStyle(fontWeight:FontWeight.bold))):null,
      );
    });
  }
  Widget _topBar()=>Padding(padding:const EdgeInsets.fromLTRB(22,14,22,12),child:Row(children:[
    Container(width:38,height:38,decoration:BoxDecoration(color:lime,borderRadius:BorderRadius.circular(12)),
      child:const Icon(Icons.sports_tennis,color:ink)),
    const SizedBox(width:10),
    const Text('RALLY',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900,letterSpacing:2)),
    const Text('UP',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:lime,letterSpacing:2)),
    const Spacer(),
    const Icon(Icons.location_on_outlined,color:lime,size:18),
    const SizedBox(width:4),
    const Text('Hyderabad',style:TextStyle(color:muted)),
    const SizedBox(width:12),
    CircleAvatar(backgroundColor:panel,child:const Text('H',style:TextStyle(color:lime,fontWeight:FontWeight.bold))),
  ]));
  Widget _home()=>ListView(padding:const EdgeInsets.fromLTRB(22,8,22,90),children:[
    const Text('YOUR NEXT GAME STARTS HERE',style:TextStyle(color:lime,fontSize:11,fontWeight:FontWeight.bold,letterSpacing:1.6)),
    const SizedBox(height:8),
    const Text('Play more.\\nConnect better.',style:TextStyle(fontSize:34,height:1.12,fontWeight:FontWeight.w900)),
    const SizedBox(height:18),
    Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(
      gradient:const LinearGradient(colors:[Color(0xFF263B42),Color(0xFF18252D)]),
      borderRadius:BorderRadius.circular(22),border:Border.all(color:lime.withOpacity(.25))),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Row(children:[Icon(Icons.bolt,color:lime),SizedBox(width:6),Text('FIND YOUR GAME',style:TextStyle(color:lime,fontWeight:FontWeight.bold,letterSpacing:1))]),
        const SizedBox(height:10),const Text('Good games happen\\nwhen players connect.',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
        const SizedBox(height:14),Wrap(spacing:8,runSpacing:8,children:[
          _stat('${matches.length}','Open games'),_stat('${joined.length}','Joined'),_stat('${bookings.length}','Bookings')]),
      ])),
    const SizedBox(height:25),_section('Choose your sport','Explore games'),
    Wrap(spacing:9,runSpacing:9,children:sports.map((s)=>_sportChip(s)).toList()),
    const SizedBox(height:25),_section('Games near you','See all',onTap:()=>setState(()=>tab=1)),
    ...matches.where((m)=>selectedSport=='All'||m.sport==selectedSport).take(3).map(_matchCard),
  ]);
  Widget _stat(String n,String label)=>Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:9),
    decoration:BoxDecoration(color:Colors.white.withOpacity(.07),borderRadius:BorderRadius.circular(12)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(n,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:lime)),
      Text(label,style:const TextStyle(fontSize:11,color:muted))]));
  Widget _section(String title,String action,{VoidCallback? onTap})=>Padding(
    padding:const EdgeInsets.only(bottom:13),child:Row(children:[
      Text(title,style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold)),
      const Spacer(),GestureDetector(onTap:onTap,child:Text(action,style:const TextStyle(color:lime,fontWeight:FontWeight.bold))),
    ]));
  Widget _sportChip(String s){
    final active=selectedSport==s;
    return ChoiceChip(label:Text(s),selected:active,onSelected:(_)=>setState(()=>selectedSport=s),
      selectedColor:lime,backgroundColor:panel,labelStyle:TextStyle(color:active?ink:Colors.white,fontWeight:FontWeight.w600),
      side:BorderSide.none);
  }
  IconData _sportIcon(String s)=>switch(s){
    'Badminton'=>Icons.sports_tennis,'Cricket'=>Icons.sports_cricket,'Football'=>Icons.sports_soccer,
    'Tennis'=>Icons.sports_tennis,'Basketball'=>Icons.sports_basketball,'Volleyball'=>Icons.sports_volleyball,
    'Pickleball'=>Icons.sports_tennis,_=>Icons.sports,
  };
  Widget _matchCard(MatchItem m)=>Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(15),
    decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:Colors.white.withOpacity(.05))),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:lime.withOpacity(.12),borderRadius:BorderRadius.circular(12)),
        child:Icon(_sportIcon(m.sport),color:lime)),const SizedBox(width:10),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(m.title,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:15)),
          Text('${m.sport} • ${m.level}',style:const TextStyle(color:muted,fontSize:12))])),
        Text('₹${m.fee.toStringAsFixed(0)}',style:const TextStyle(color:lime,fontWeight:FontWeight.bold,fontSize:16)),
      ]),
      const SizedBox(height:13),
      Row(children:[const Icon(Icons.location_on_outlined,size:15,color:muted),const SizedBox(width:4),Expanded(child:Text(m.venue,style:const TextStyle(color:muted,fontSize:12))),
        const Icon(Icons.calendar_today_outlined,size:14,color:muted),const SizedBox(width:5),Text('${m.date} • ${m.time}',style:const TextStyle(color:muted,fontSize:11))]),
      const SizedBox(height:13),
      Row(children:[Text('${m.players}/${m.capacity} players',style:const TextStyle(color:muted,fontSize:12)),
        const SizedBox(width:9),Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(
          value:m.players/m.capacity,minHeight:5,backgroundColor:bg,color:lime))),
        const SizedBox(width:10),
        FilledButton(onPressed:joined.contains(m.id)||m.players>=m.capacity?null:()=>_join(m),
          style:FilledButton.styleFrom(backgroundColor:lime,foregroundColor:ink,disabledBackgroundColor:Colors.white12),
          child:Text(joined.contains(m.id)?'Joined':m.players>=m.capacity?'Full':'Join')),
      ]),
    ]));
  Widget _discover()=>ListView(padding:const EdgeInsets.fromLTRB(22,10,22,90),children:[
    const Text('Discover games',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),
    const SizedBox(height:6),const Text('Find your people. Find your game.',style:TextStyle(color:muted)),
    const SizedBox(height:18),Wrap(spacing:8,runSpacing:8,children:sports.map(_sportChip).toList()),
    const SizedBox(height:16),
    ...matches.where((m)=>selectedSport=='All'||m.sport==selectedSport).map(_matchCard),
    if(matches.where((m)=>selectedSport=='All'||m.sport==selectedSport).isEmpty)
      const Center(child:Padding(padding:EdgeInsets.all(30),child:Text('No games found. Create the first one!'))),
  ]);
  Widget _bookings()=>ListView(padding:const EdgeInsets.all(22),children:[
    const Text('My bookings',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),
    const SizedBox(height:8),const Text('Your upcoming sports sessions.',style:TextStyle(color:muted)),
    const SizedBox(height:18),
    ...bookings.map((b)=>Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(16),
      decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(15)),
      child:Row(children:[const Icon(Icons.sports,color:lime),const SizedBox(width:12),Expanded(child:Text(b)),const Icon(Icons.check_circle,color:lime)]))),
    if(bookings.isEmpty) _empty(Icons.calendar_month,'No bookings yet','Court bookings you add will appear here.'),
    const SizedBox(height:15),
    const Text('Quick demo court booking',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17)),
    const SizedBox(height:10),
    ...['Smash Arena • Badminton • 6:00 PM','Turf Central • Football • 7:30 PM','Ace Tennis Club • Tennis • 7:00 AM'].map((v)=>ListTile(
      tileColor:panel,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(13)),title:Text(v,style:const TextStyle(fontSize:13)),
      trailing:TextButton(onPressed:(){setState(()=>bookings.add(v));_save();},child:const Text('Book',style:TextStyle(color:lime))))),
  ]);
  Widget _leaderboard()=>ListView(padding:const EdgeInsets.all(22),children:[
    const Text('Leaderboard',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),
    const SizedBox(height:6),const Text('The players setting the pace.',style:TextStyle(color:muted)),
    const SizedBox(height:18),
    ...[['1','Aarav Mehta','1,850','🏆'],['2','Maya Reddy','1,720','🥈'],['3','Kabir Shah','1,610','🥉'],['4','Isha Nair','1,480','⭐'],['5','You','1,250','⚡']].map((p)=>Container(
      margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(15),
      decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(15)),
      child:Row(children:[Text(p[3],style:const TextStyle(fontSize:22)),const SizedBox(width:12),
        Text('#${p[0]}',style:const TextStyle(color:lime,fontWeight:FontWeight.bold)),
        const SizedBox(width:12),Expanded(child:Text(p[1],style:const TextStyle(fontWeight:FontWeight.w600))),
        Text('${p[2]} pts',style:const TextStyle(color:lime,fontWeight:FontWeight.bold))]))),
    const SizedBox(height:12),const Text('Points are sample data for demonstration.',style:TextStyle(color:muted,fontSize:11)),
  ]);
  Widget _profile()=>ListView(padding:const EdgeInsets.all(22),children:[
    const Text('Your profile',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),
    const SizedBox(height:20),Center(child:Column(children:[
      const CircleAvatar(radius:43,backgroundColor:lime,child:Text('H',style:TextStyle(color:ink,fontSize:32,fontWeight:FontWeight.w900))),
      const SizedBox(height:10),const Text('Harini',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
      const Text('Sports enthusiast • Hyderabad',style:TextStyle(color:muted)),
      const SizedBox(height:15),Wrap(spacing:8,children:[_stat('${joined.length}','Games joined'),_stat('${bookings.length}','Bookings')]),
    ])),
    const SizedBox(height:25),const Text('Favourite sports',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17)),
    const SizedBox(height:10),Wrap(spacing:8,runSpacing:8,children:['Badminton','Cricket','Football','Tennis'].map((s)=>Chip(
      avatar:Icon(_sportIcon(s),size:16,color:lime),label:Text(s),backgroundColor:panel,side:BorderSide.none)).toList()),
    const SizedBox(height:20),const Text('About RallyUp',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17)),
    const SizedBox(height:8),const Text('RallyUp brings sports communities together. Discover games, meet players and make every day a game day.',style:TextStyle(color:muted,height:1.5)),
  ]);
  Widget _empty(IconData icon,String title,String desc)=>Container(padding:const EdgeInsets.all(24),
    decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(16)),
    child:Column(children:[Icon(icon,size:35,color:lime),const SizedBox(height:9),Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),
      const SizedBox(height:5),Text(desc,textAlign:TextAlign.center,style:const TextStyle(color:muted,fontSize:12))]));
}

class CreateMatchDialog extends StatefulWidget {
  final ValueChanged<MatchItem> onCreate;
  const CreateMatchDialog({super.key,required this.onCreate});
  @override State<CreateMatchDialog> createState()=>_CreateMatchDialogState();
}
class _CreateMatchDialogState extends State<CreateMatchDialog>{
  final title=TextEditingController(),venue=TextEditingController(),fee=TextEditingController(text:'150');
  String sport='Badminton',level='Intermediate';
  int capacity=4;
  @override void dispose(){title.dispose();venue.dispose();fee.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>AlertDialog(
    backgroundColor:panel,title:const Text('Create a match'),
    content:SingleChildScrollView(child:SizedBox(width:380,child:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:title,decoration:const InputDecoration(labelText:'Match title',hintText:'Sunday doubles game')),
      const SizedBox(height:10),DropdownButtonFormField<String>(value:sport,decoration:const InputDecoration(labelText:'Sport'),
        items:['Badminton','Cricket','Football','Tennis','Basketball','Pickleball','Volleyball'].map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),onChanged:(v)=>setState(()=>sport=v!)),
      const SizedBox(height:10),TextField(controller:venue,decoration:const InputDecoration(labelText:'Venue',hintText:'Sports arena, area')),
      const SizedBox(height:10),DropdownButtonFormField<String>(value:level,decoration:const InputDecoration(labelText:'Skill level'),
        items:['Beginner','Intermediate','Advanced','All levels'].map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),onChanged:(v)=>setState(()=>level=v!)),
      const SizedBox(height:10),DropdownButtonFormField<int>(value:capacity,decoration:const InputDecoration(labelText:'Total players'),
        items:[2,4,6,8,10,12,14,16,20].map((n)=>DropdownMenuItem(value:n,child:Text('$n players'))).toList(),onChanged:(v)=>setState(()=>capacity=v!)),
      const SizedBox(height:10),TextField(controller:fee,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Fee per player (₹)')),
    ]))),
    actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),
      FilledButton(onPressed:(){
        if(title.text.trim().isEmpty||venue.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Please enter a title and venue')));return;}
        widget.onCreate(MatchItem(id:DateTime.now().microsecondsSinceEpoch.toString(),sport:sport,title:title.text.trim(),venue:venue.text.trim(),
          date:'Tomorrow',time:'6:00 PM',level:level,host:'You',players:1,capacity:capacity,fee:double.tryParse(fee.text)??150));
        Navigator.pop(context);
      },style:FilledButton.styleFrom(backgroundColor:lime,foregroundColor:ink),child:const Text('Create')),
    ]);
}

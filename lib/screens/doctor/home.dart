import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DoctorHomeScreen extends StatefulWidget {
  final String doctorId;
  const DoctorHomeScreen({super.key, required this.doctorId});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _tabIndex = 0;
  int selectedDayIndex = 0;

  List<DateTime> get next7Days {
    final now = DateTime.now();
    return List.generate(7, (i) => DateTime(now.year, now.month, now.day + i));
  }

  //------------------------------------------------------------------------------
  // ROOT UI
  //------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Doctor Dashboard"),
        backgroundColor: const Color.fromARGB(255, 64, 119, 174),
        foregroundColor: Colors.white,
      ),
      body: _tabIndex == 0 ? dashboardUI() : availabilityUI(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i)=>setState(()=>_tabIndex=i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined),label:"Dashboard"),
          NavigationDestination(icon: Icon(Icons.calendar_month),label:"Availability"),
        ],
      ),
    );
  }

  //==============================================================================
  // DASHBOARD UI — Improved Visual Polishing
  //==============================================================================
  Widget dashboardUI(){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          headerCard(),
          const SizedBox(height:18),
          dashboardStatsRow(),   // prettier numbers instead of raw text
          const SizedBox(height:20),

          const Text("Today's Schedule",style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),
          const SizedBox(height:10),
          todaysAppointmentsList()
        ],
      ),
    );
  }

  //---------------- Doctor Header -----------------
  Widget headerCard(){
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection("doctors").doc(widget.doctorId).get(),
      builder: (_,snap){
        if(!snap.hasData) return shimmer("Loading doctor info");

        var d=snap.data!.data() as Map<String,dynamic>;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors:[const Color.fromARGB(255, 74, 145, 171),const Color.fromARGB(255, 43, 126, 174)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow:[BoxShadow(color: const Color.fromARGB(255, 79, 141, 182),blurRadius:6,offset:Offset(0,3))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d["name"] ?? "Doctor",
                  style: const TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:Colors.white)),
              const SizedBox(height:4),
              Text(d["specialty"] ?? "Specialist",
                  style: const TextStyle(fontSize:16,color:Colors.white70)),
            ],
          ),
        );
      },
    );
  }

  //---------------- COUNT CARDS -----------------
  Widget dashboardStatsRow(){
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
        .collection("doctors").doc(widget.doctorId)
        .collection("appointments").get(),

      builder:(context,snap){
        int total = snap.hasData ? snap.data!.size : 0;

        return Row(
          children:[
            statCard(
              title:"Appointments",
              value:"$total",
              icon:Icons.calendar_today,
              color:Colors.blueAccent
            ),
            statCard(
              title:"Availability",
              value:"Edit",
              icon:Icons.schedule,
              color:Color.fromARGB(255, 52, 88, 235),
              onTap:()=>setState(()=>_tabIndex=1)
            ),
          ],
        );
      },
    );
  }

  Widget statCard({required String title,required String value,required IconData icon,
    Color? color, VoidCallback? onTap}) {

    return Expanded(
      child: GestureDetector(
        onTap:onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal:8,vertical:4),
          padding: const EdgeInsets.symmetric(vertical:18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow:[BoxShadow(color:Colors.black12,blurRadius:6,offset:Offset(0,3))]
          ),
          child: Column(children:[
            Icon(icon,size:30,color:color),
            const SizedBox(height:6),
            Text(value,style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:color)),
            Text(title,style:const TextStyle(color:Colors.black54)),
          ]),
        ),
      ),
    );
  }

  //---------------- SCHEDULE LIST -----------------
  Widget todaysAppointmentsList(){
    DateTime now=DateTime.now();
    final start = Timestamp.fromDate(DateTime(now.year,now.month,now.day));
    final end   = Timestamp.fromDate(DateTime(now.year,now.month,now.day+1));

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("doctors")
        .doc(widget.doctorId).collection("appointments")
        .where("slotStart",isGreaterThanOrEqualTo:start)
        .where("slotStart",isLessThan:end)
        .orderBy("slotStart").snapshots(),

      builder:(_,snap){
        if(!snap.hasData) return shimmer("Loading appointments...");
        if(snap.data!.docs.isEmpty) return emptyBox("No appointments today");

        return Column(children:snap.data!.docs.map((a){
          DateTime time=(a["slotStart"] as Timestamp).toDate();
          String readable=DateFormat("h:mm a").format(time);
          String pid=a["patientId"];

          return scheduleTile("Patient $pid at $readable");
        }).toList());
      },
    );
  }

  Widget scheduleTile(String text)=>Container(
    margin:const EdgeInsets.only(bottom:10),
    padding:const EdgeInsets.all(14),
    decoration:BoxDecoration(
      color:Colors.teal.shade50,borderRadius:BorderRadius.circular(10)),
    child:Row(children:[
      Icon(Icons.person,color:Color.fromARGB(255, 83, 136, 179)),
      const SizedBox(width:8),
      Text(text,style:const TextStyle(fontWeight:FontWeight.w600)),
    ])
  );

  Widget emptyBox(String msg)=>Container(
    width:double.infinity,padding:const EdgeInsets.all(18),
    decoration:BoxDecoration(borderRadius:BorderRadius.circular(14),color:Colors.grey.shade200),
    child:Center(child:Text(msg,style:const TextStyle(fontWeight:FontWeight.w600)))
  );
  Widget shimmer(String msg)=>emptyBox(msg);

  //==============================================================================
  // AVAILABILITY TAB UI ⭐
  //==============================================================================
  Widget availabilityUI(){
    final days=next7Days;
    final selected=days[selectedDayIndex];

    return Column(children:[
      calendarStrip(days),
      const Padding(
        padding:EdgeInsets.all(10),
        child:Text("Tap hours to toggle availability",style:TextStyle(fontWeight:FontWeight.bold))),
      Expanded(child: availabilityGrid(selected))
    ]);
  }

  Widget calendarStrip(List<DateTime> days){
    return SizedBox(height:85,child:
      ListView.builder(scrollDirection:Axis.horizontal,itemCount:days.length,
        itemBuilder:(_,i){
          final d=days[i]; final selected=i==selectedDayIndex;
          return GestureDetector(
            onTap:()=>setState(()=>selectedDayIndex=i),
            child:Container(
              width:70,margin:const EdgeInsets.all(8),
              decoration:BoxDecoration(
                color:selected?const Color.fromARGB(255, 78, 166, 224):Colors.white,
                borderRadius:BorderRadius.circular(10),
                border:Border.all(color:selected?const Color.fromARGB(255, 84, 147, 187):Colors.black26)
              ),
              child:Column(
                mainAxisAlignment:MainAxisAlignment.center,
                children:[
                  Text(DateFormat("EEE").format(d),style:TextStyle(color:selected?Colors.white:Colors.black)),
                  Text("${d.day}",style:TextStyle(fontSize:20,color:selected?Colors.white:Colors.teal)),
                ])
            ),
          );
        })
    );
  }

  /// Availability Toggle
  Widget availabilityGrid(DateTime date){
    final hours=List.generate(8,(i)=>DateTime(date.year,date.month,date.day,9+i));

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("doctors")
        .doc(widget.doctorId).collection("unavailability").snapshots(),

      builder:(_,snap){
        Set<String> blocked={};
        if(snap.hasData){
          for(var d in snap.data!.docs){
            blocked.add((d["slot"]as Timestamp).toDate().toIso8601String());
          }
        }

        return GridView.builder(
          padding:const EdgeInsets.all(16),
          itemCount:hours.length,
          gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:4,mainAxisSpacing:12,crossAxisSpacing:12),
          itemBuilder:(_,i){
            final slot=hours[i];
            final isBlocked = blocked.contains(slot.toIso8601String());

            return GestureDetector(
              onTap:()=>toggleSlot(slot,isBlocked),
              child:Container(
                decoration:BoxDecoration(
                  borderRadius:BorderRadius.circular(10),
                  color:isBlocked?Colors.red.shade300:const Color.fromARGB(255, 129, 183, 199)),
                child:Center(
                  child:Text(DateFormat("h a").format(slot),
                      style:const TextStyle(fontWeight:FontWeight.bold))))
            );
          });
      }
    );
  }

  Future toggleSlot(DateTime slot,bool isBlocked) async{
    final ref=FirebaseFirestore.instance
      .collection("doctors").doc(widget.doctorId)
      .collection("unavailability").doc(slot.toIso8601String());

    isBlocked ? await ref.delete() : await ref.set({"slot":Timestamp.fromDate(slot)});
  }
}

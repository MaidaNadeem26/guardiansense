// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [

    {
      "icon": Icons.favorite_outline_rounded,
      "iconColor": const Color(0xFF5B8CFF),
      "title": "Caring real-time monitoring",
      "desc":
      "Stay connected with your loved ones through gentle and respectful monitoring.",
    },

    {
      "icon": Icons.notifications_active_outlined,
      "iconColor": const Color(0xFFFF9F43),
      "title": "Smart safety alerts",
      "desc":
      "GuardianSense identifies unusual patterns and keeps you informed when needed.",
    },

    {
      "icon": Icons.groups_outlined,
      "iconColor": const Color(0xFF34B27B),
      "title": "Connected family network",
      "desc":
      "Bring your family together and provide support whenever it matters most.",
    },

  ];


  void _nextPage(){

    if(_currentPage < _pages.length-1){

      _controller.nextPage(
        duration: const Duration(milliseconds:400),
        curve: Curves.easeInOut,
      );

    }else{

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

    }

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            colors: [
              Color(0xFFEAF3FF),
              Colors.white,
            ],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

          ),

        ),


        child: SafeArea(

          child: Column(

            children: [


              Expanded(

                child: PageView.builder(

                  controller: _controller,
                  itemCount: _pages.length,

                  onPageChanged: (index){

                    setState(() {
                      _currentPage=index;
                    });

                  },


                  itemBuilder: (context,index){

                    final page=_pages[index];


                    return Padding(

                      padding: const EdgeInsets.symmetric(horizontal:35),

                      child: Column(

                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [


                          Container(

                            height:150,
                            width:150,

                            decoration: BoxDecoration(

                              shape: BoxShape.circle,

                              color: Colors.white,

                              boxShadow: [

                                BoxShadow(

                                  color: Colors.blue.withValues(alpha: 0.15),
                                  blurRadius:30,
                                  spreadRadius:5,

                                )

                              ],

                            ),


                            child: Center(

                              child: Icon(

                                page["icon"],

                                size:65,

                                color:page["iconColor"],

                              ),

                            ),

                          ),



                          const SizedBox(height:45),



                          Text(

                            page["title"],

                            textAlign:TextAlign.center,

                            style:const TextStyle(

                              fontSize:25,

                              fontWeight:FontWeight.w700,

                              color:Color(0xFF1F2937),

                            ),

                          ),



                          const SizedBox(height:15),



                          Text(

                            page["desc"],

                            textAlign:TextAlign.center,

                            style:TextStyle(

                              fontSize:15,

                              height:1.5,

                              color:Colors.grey[600],

                            ),

                          ),


                        ],

                      ),

                    );


                  },


                ),

              ),



              // Page indicators

              Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children:List.generate(

                  _pages.length,

                      (index)=>AnimatedContainer(

                    duration:const Duration(milliseconds:300),

                    margin:const EdgeInsets.symmetric(horizontal:5),

                    height:8,

                    width:_currentPage==index ? 28:8,

                    decoration:BoxDecoration(

                      color:_currentPage==index

                          ? const Color(0xFF5B8CFF)

                          : Colors.grey.shade300,

                      borderRadius:BorderRadius.circular(20),

                    ),

                  ),

                ),

              ),



              const SizedBox(height:35),



              Padding(

                padding:const EdgeInsets.symmetric(horizontal:25),

                child:SizedBox(

                  width:double.infinity,

                  height:55,


                  child:ElevatedButton(

                    onPressed:_nextPage,


                    style:ElevatedButton.styleFrom(

                      backgroundColor:

                      const Color(0xFF5B8CFF),


                      elevation:8,


                      shadowColor:

                      Colors.blue.withValues(alpha: 0.3),


                      shape:RoundedRectangleBorder(

                        borderRadius:

                        BorderRadius.circular(18),

                      ),

                    ),



                    child:Text(

                      _currentPage==_pages.length-1

                          ? "Get Started"

                          :"Continue",


                      style:const TextStyle(

                        color:Colors.white,

                        fontSize:17,

                        fontWeight:FontWeight.w600,

                      ),

                    ),


                  ),

                ),

              ),



              const SizedBox(height:35),


            ],

          ),

        ),

      ),

    );

  }
}

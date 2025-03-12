import 'package:flutter/material.dart';

const kgreen = Color(0xff1D5254);

const header =  TextStyle(
  fontFamily: 'Gladolia',
  color: Colors.white,
  fontSize: 45,
);

const hometitle = TextStyle(
  fontFamily: 'BalsamiqSans',
  color: Colors.white,
  fontSize: 20
);

const homedescription = TextStyle(
  color: Colors.white,
  fontFamily: 'BalsamiqSans',
  fontSize: 15
);

const homedate = TextStyle(
  color: Colors.black,
  fontFamily: 'BalsamiqSans',
  fontSize: 13
);

const notetitle = TextStyle(
  fontFamily: 'BalsamiqSans',
  fontSize: 25
);

const notedescription = TextStyle(
  fontSize: 15
);

const settingstitle = TextStyle(
  fontFamily: 'BalsamiqSans',
  color: Colors.white,
  fontSize: 24
);

const settingstheme = TextStyle(
  fontFamily: 'BalsamiqSans',
  fontSize: 15
);

const date = TextStyle(
  color: Colors.white,
  fontFamily: 'BalsamiqSans',
  fontSize: 18,
);

moreoption(name, IconData icon, GestureTapCallback data) => Column(
  children: [
    GestureDetector(
      onTap: data,
      child: Padding(
        padding: const EdgeInsets.only(top: 8,left: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                icon,
                color: Colors.white,
                size: 15,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'BalsamiqSans',
                fontSize: 15,
                color: Colors.white
              ),
            ),
          ],
        ),
      ),
    )
  ],
);

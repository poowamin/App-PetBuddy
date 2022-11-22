import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/firestorage_api.dart';
import 'package:flutter/material.dart';
import 'package:pet_buddy/constants.dart';
import 'package:pet_buddy/model/report.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils.dart';
import 'package:pet_buddy/screen/admin/tab/tap_detail_report.dart';

class ReportList extends StatefulWidget {
  const ReportList({
    super.key,
  });

  @override
  _ReportList createState() => _ReportList();
}

class _ReportList extends State<ReportList> {
  final _numberToMonthMap = {
    1: "ม.ค.",
    2: "ก.พ.",
    3: "มี.ค.",
    4: "เม.ย.",
    5: "พ.ค.",
    6: "มิ.ย.",
    7: "ก.ค.",
    8: "ส.ค.",
    9: "ก.ย.",
    10: "ต.ค.",
    11: "พ.ย.",
    12: "ธ.ค.",
  };

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'รายงานทั้งหมด',
        style: GoogleFonts.kanit(),
      )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<Report>>(
              stream: FirebaseFirestore.instance
                  .collection('report')
                  .orderBy(ReportField.createdAt, descending: true)
                  .snapshots()
                  .map((snapshot) => snapshot.docs
                      .map((doc) => Report.fromJson(doc.data()))
                      .toList()),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'ไม่มีข้อมูล',
                          style: GoogleFonts.kanit(
                            textStyle: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    } else {
                      final reports = snapshot.data;

                      return reports!.isEmpty
                          ? Center(
                              child: Text(
                                'ไม่มีข้อมูล',
                                style: GoogleFonts.kanit(
                                  textStyle: const TextStyle(fontSize: 24),
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: reports.length,
                              itemBuilder: (context, index) {
                                final report = reports[index];

                                return reportWidget(report);
                              },
                            );
                    }
                }
              },
            )
          ],
        ),
      ),
    );
  }

  reportWidget(Report report) => SizedBox(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: GestureDetector(
            onTap: () async {},
            onLongPress: () => editDeleteMethod(
              context,
              report,
            ),
            child: Card(
              child: InkWell(
                splashColor: Colors.grey.withAlpha(50),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TapDetailReport(
                      report: report,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: report.photo,
                      imageBuilder: (context, imageProvider) => Image.network(
                        report.photo,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 152,
                      ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/no_image.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 152,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  report.pet_name,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.kanit(
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.file_copy,
                                  color: Colors.green,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    report.detail,
                                    style: GoogleFonts.kanit(),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('user')
                                  .doc(report.user_id)
                                  .get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.hasError &&
                                    (snapshot.hasData &&
                                        !snapshot.data!.exists)) {
                                  return const Text("");
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  Map<String, dynamic> data = snapshot.data!
                                      .data() as Map<String, dynamic>;
                                  Timestamp t = data['time'] as Timestamp;
                                  DateTime date = t.toDate();
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ผู้แจ้ง ${data['name']}',
                                        style: Myconstant().textStyle1(),
                                      ),
                                      Text(
                                        '${date.day} ${_numberToMonthMap[date.month]} ${date.year + 543}\n${date.hour}:${date.minute}:${date.second}',
                                        style: Myconstant().textStyle7(),
                                      ),
                                    ],
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

editDeleteMethod(BuildContext context, Report report) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          '⭐ แจ้งเตือน',
          style: GoogleFonts.kanit(),
        ),
        content: Text(
          "คุณต้องการลบรายงาน ใช่หรือไม่?",
          style: GoogleFonts.kanit(),
        ),
        actions: <Widget>[
          TextButton(
            // ปิด popup
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'ไม่ใช่',
              style: GoogleFonts.kanit(),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);

              await FirebaseFirestore.instance
                  .collection('report')
                  .doc(report.report_id)
                  .delete()
                  .whenComplete(() => print('Delete'));

              await FireStorageApi.removePhoto(report.photo);
            },
            child: Text(
              'ใช่',
              style: GoogleFonts.kanit(),
            ),
          ),
        ],
      );
    },
  );
}

// tapdetails(BuildContext context, Report report) async {
//   return await showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(
//           '',
//           textAlign: TextAlign.center,
//           style: GoogleFonts.kanit(),
//         ),
//         content: Text(
//           'แจ้งเตือน',
//           textAlign: TextAlign.center,
//           style: GoogleFonts.kanit(),
//           textScaleFactor: 1,
//         ),
//         actions: <Widget>[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               TextButton(
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   Utils.sendPushNotifications(
//                     context,
//                     title: 'การแจ้งเตือน',
//                     body: 'แอดมินได้รับเรื่องร้องเรียนแล้ว',
//                     token: 'admin',
//                   );
//                 },
//                 child: Text(
//                   'รับเรื่อง',
//                   style: GoogleFonts.kanit(),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   Utils.sendPushNotifications(
//                     context,
//                     title: 'การแจ้งเตือน',
//                     body: 'แอดมินได้ดำเนินเรื่องเรียบร้อยแล้ว',
//                     token: 'admin',
//                   );
//                 },
//                 child: Text(
//                   'เดินเนินการเสร็จสิ้น',
//                   style: GoogleFonts.kanit(),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/constants.dart';
import 'package:pet_buddy/model/report.dart';

class TapDetailReport extends StatefulWidget {
  final Report report;
  const TapDetailReport({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  State<TapDetailReport> createState() => _TapDetailReportState();
}

class _TapDetailReportState extends State<TapDetailReport> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'รายละเอียด',
          style: GoogleFonts.kanit(),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Column(
                  children: [
                    reportDetailWidget(widget.report),
                    checkDatail(),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  reportDetailWidget(Report report) => SizedBox(
        width: 352,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            report.pet_name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.kanit(
                              textStyle: const TextStyle(
                                fontSize: 24,
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
                            width: 16,
                          ),
                          Expanded(
                            child: Text(
                              report.detail,
                              style: GoogleFonts.kanit(
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('user')
                            .doc(report.user_id)
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasError &&
                              (snapshot.hasData && !snapshot.data!.exists)) {
                            return const Text('');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            Map<String, dynamic> data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            Timestamp t = data['time'] as Timestamp;
                            DateTime date = t.toDate();
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ผู้แจ้ง ${data['name']}',
                                  style: Myconstant().textStyle1(),
                                ),
                                Text(
                                  '${date.day} ${_numberToMonthMap[date.month]} ${date.year + 543}\nเวลาที่แจ้ง\f${date.hour}:${date.minute}:${date.second}',
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
              ],
            ),
          ),
        ),
      );

  checkDatail() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                  value: widget.report.isCheck1,
                  onChanged: (value) =>
                      setState(() => widget.report.isCheck1 = value!)),
              Text('รับเรื่อง', style: GoogleFonts.kanit(fontSize: 16)),
              confirmDetail1(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                  value: widget.report.isCheck2,
                  onChanged: (value) =>
                      setState(() => widget.report.isCheck2 = value!)),
              Text('กำลังดำเนินการ', style: GoogleFonts.kanit(fontSize: 16)),
              confirmDetail2(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                  value: widget.report.isCheck3,
                  onChanged: (value) =>
                      setState(() => widget.report.isCheck3 = value!)),
              Text('ดำเนินการเรียบร้อย',
                  style: GoogleFonts.kanit(fontSize: 16)),
              confirmDetail3(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                  value: widget.report.isCheck4,
                  onChanged: (value) =>
                      setState(() => widget.report.isCheck4 = value!)),
              Text('ปฏิเสธการร้องเรียน',
                  style: GoogleFonts.kanit(fontSize: 16, color: Colors.red)),
              confirmDetail4(),
            ],
          ),
        ],
      );

  confirmDetail1() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('report')
                .doc(widget.report.report_id)
                .update({'isCheck1': true}).then(
                    (value) => Navigator.pop(context));
          },
          child: Text(
            'บันทึก',
            style: GoogleFonts.kanit(),
          ),
        ),
      );

  confirmDetail2() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('report')
                .doc(widget.report.report_id)
                .update({'isCheck2': true}).then(
                    (value) => Navigator.pop(context));
          },
          child: Text(
            'บันทึก',
            style: GoogleFonts.kanit(),
          ),
        ),
      );

  confirmDetail3() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('report')
                .doc(widget.report.report_id)
                .update({'isCheck3': true}).then(
                    (value) => Navigator.pop(context));
          },
          child: Text(
            'บันทึก',
            style: GoogleFonts.kanit(),
          ),
        ),
      );

  confirmDetail4() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('report')
                .doc(widget.report.report_id)
                .update({'isCheck4': true}).then(
                    (value) => Navigator.pop(context));
          },
          child: Text(
            'บันทึก',
            style: GoogleFonts.kanit(),
          ),
        ),
      );
}

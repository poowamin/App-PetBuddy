import 'package:flutter/material.dart';
import 'package:flutter_thailand_provinces/dao/province_dao.dart';

class ChooseProvinceeDialog extends StatefulWidget {
  final List<ProvinceDao> listProvinces;
  final TextStyle styleTitle;
  final TextStyle styleSubTitle;
  final TextStyle styleTextNoData;
  final TextStyle styleTextSearch;
  final TextStyle styleTextSearchHint;
  final double borderRadius;
  final Color colorBackgroundSearch;
  final Color colorBackgroundHeader;
  final Color colorLine;
  final Color colorLineHeader;
  final Color colorBackgroundDialog;

  const ChooseProvinceeDialog(
      {super.key, required this.listProvinces,
      required this.styleTitle,
      required this.styleSubTitle,
      required this.styleTextNoData,
      required this.styleTextSearch,
      required this.styleTextSearchHint,
      required this.colorBackgroundHeader,
      required this.colorBackgroundSearch,
      required this.colorBackgroundDialog,
      required this.colorLine,
      required this.colorLineHeader,
      this.borderRadius = 16});

  static show(BuildContext context,
      {required List<ProvinceDao> listProvinces,
      required TextStyle styleTitle,
      required TextStyle styleSubTitle,
      required TextStyle styleTextNoData,
      required TextStyle styleTextSearch,
      required TextStyle styleTextSearchHint,
      required Color colorBackgroundSearch,
      required Color colorBackgroundHeader,
      required Color colorBackgroundDialog,
      required Color colorLine,
      required Color colorLineHeader,
      double borderRadius = 16}) {
    return showDialog(
        context: context,
        builder: (context) {
          return ChooseProvinceeDialog(
            listProvinces: listProvinces,
            styleTitle: styleTitle,
            styleSubTitle: styleSubTitle,
            styleTextNoData: styleTextNoData,
            styleTextSearch: styleTextSearch,
            colorBackgroundSearch: colorBackgroundSearch,
            colorBackgroundHeader: colorBackgroundHeader,
            colorBackgroundDialog: colorBackgroundDialog,
            colorLine: colorLine,
            colorLineHeader: colorLineHeader,
            borderRadius: borderRadius,
            styleTextSearchHint: styleTextSearchHint,
          );
        });
  }

  @override
  _ChooseProvinceeDialogState createState() => _ChooseProvinceeDialogState();
}

class _ChooseProvinceeDialogState extends State<ChooseProvinceeDialog> {
  late List<ProvinceDao> listProvincesFilter;
  final TextEditingController _searchProvinceController =
      TextEditingController();

  @override
  void initState() {
    listProvincesFilter = List.of(widget.listProvinces);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: widget.colorBackgroundDialog,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
//          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
              width: 300,
              height: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildSearchContainer(),
                  Container(
                    color: widget.colorLineHeader,
                    height: 4,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(widget.borderRadius))),
                      padding: const EdgeInsets.all(8),
                      child: buildListView(),
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

  Widget buildListView() {
    return Stack(
      children: <Widget>[
        ListView.builder(
            itemCount: listProvincesFilter.length,
            itemBuilder: (context, index) {
              return buildRowProvince(listProvincesFilter[index]);
            }),
        Center(
            child: Visibility(
                visible: listProvincesFilter.isEmpty,
                child: Text(
                  "ไม่มีข้อมูล",
                  style: widget.styleTextNoData,
                )))
      ],
    );
  }

  Widget buildRowProvince(ProvinceDao province) {
    return GestureDetector(
        onTap: () {
          Navigator.pop(context, province);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    province.nameTh,
                    style: widget.styleTitle,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    province.nameEn,
                    style: widget.styleSubTitle,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: widget.colorLine,
            )
          ],
        ));
  }

  Widget buildSearchContainer() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      decoration: BoxDecoration(
          color: widget.colorBackgroundHeader,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(widget.borderRadius))),
      child: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: widget.colorBackgroundSearch,
                  borderRadius: BorderRadius.circular(8)),
              child: TextField(
                controller: _searchProvinceController,
                style: widget.styleTextSearch,
                decoration: InputDecoration.collapsed(
                    hintText: "ค้นหา", hintStyle: widget.styleTextSearchHint),
                onChanged: (text) async {
                  List<ProvinceDao> list = widget.listProvinces.where((item) {
                    text = text.toLowerCase();
                    return item.nameTh.toLowerCase().contains(text) ||
                        item.nameEn.toLowerCase().contains(text);
                  }).toList();

                  setState(() {
                    listProvincesFilter = list;
                  });
                },
              )),
        ],
      ),
    );
  }
}

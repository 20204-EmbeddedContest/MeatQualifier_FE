import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DetailPage extends StatelessWidget {
  final String imagePath;
  final String name;
  final String origin;
  final String purchaseDate;
  final String storageMethod;
  final List<int> freshnessData;

  DetailPage({
    required this.imagePath,
    required this.name,
    required this.origin,
    required this.purchaseDate,
    required this.storageMethod,
    required this.freshnessData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(name),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_sharp),
            onPressed: () {
              // Implement notification action here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '생산지',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  origin,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '구입일',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  purchaseDate,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '보관 방법',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  storageMethod,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '신선도',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0), // 좌우 여백을 줄임
                  child: SizedBox(
                    height: 150, // 그래프 높이
                    child: Stack(
                      children: [
                        LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: false,
                            ),
                            titlesData: FlTitlesData(
                              show: false,
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                left: BorderSide(
                                  color: Colors.transparent,
                                ),
                                right: BorderSide(
                                  color: Colors.transparent,
                                ),
                                top: BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                            minX: 0,
                            maxX: freshnessData.length - 1,
                            minY: 0,
                            maxY: 100,
                            lineBarsData: [
                              LineChartBarData(
                                spots: freshnessData
                                    .asMap()
                                    .entries
                                    .map((entry) => FlSpot(entry.key.toDouble(),
                                        entry.value.toDouble()))
                                    .toList(),
                                isCurved: false,
                                color: Colors.red,
                                barWidth: 2,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: Colors.white,
                                      strokeWidth: 2,
                                      strokeColor: Colors.red,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.red.withOpacity(0.3),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.withOpacity(0.3),
                                      Colors.red.withOpacity(0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children:
                                    freshnessData.asMap().entries.map((entry) {
                                  double xPosition = constraints.maxWidth /
                                      (freshnessData.length - 1) *
                                      entry.key;
                                  double yPosition = constraints.maxHeight -
                                      (entry.value.toDouble() /
                                          100 *
                                          constraints.maxHeight) -
                                      12;

                                  // 왼쪽 끝 점일 경우
                                  if (entry.key == 0) {
                                    xPosition = xPosition + 20; // 왼쪽으로 더 많이 이동
                                  }
                                  // 오른쪽 끝 점일 경우
                                  else if (entry.key ==
                                      freshnessData.length - 1) {
                                    xPosition = xPosition - 20; // 오른쪽으로 약간 이동
                                  }

                                  return Positioned(
                                    left: xPosition,
                                    top: yPosition -
                                        20, // top 값을 조정하여 점 바로 위에 텍스트 배치
                                    child: Text(
                                      entry.value.toString(),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

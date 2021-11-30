import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

final List<String> listImage = [
  'assets/images/header.jpg',
  'assets/images/header.jpg',
  'assets/images/header.jpg',
  'assets/images/header.jpg',
  'assets/images/header.jpg',
];

final List<Widget> listImageSlider = listImage
    .map(
      (item) => ClipRRect(
        child: Stack(
          children: <Widget>[
            ClipPath(
              clipper: WaveClipperTwo(flip: true),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(item),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    )
    .toList();

class CarouselSliderCustom extends StatefulWidget
    implements PreferredSizeWidget {
  @override
  final Size preferredSize; // default is 56.0

  const CarouselSliderCustom({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  _CarouselSliderCustomState createState() => _CarouselSliderCustomState();
}

class _CarouselSliderCustomState extends State<CarouselSliderCustom> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CarouselSlider(
                items: listImageSlider,
                carouselController: _controller,
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
              ),
              Positioned(
                top: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: listImage.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(
                                _current == entry.key ? 0.9 : 0.4)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Positioned(
                top: 170,
                left: 10,
                child: Text(
                  "Tiền Giang",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

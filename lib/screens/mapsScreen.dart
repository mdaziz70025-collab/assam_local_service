import 'package:basp/Provider/map_data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Mappage extends StatefulWidget {
  const Mappage({Key? key}) : super(key: key);

  @override
  _MappageState createState() => _MappageState();
}

class _MappageState extends State<Mappage> {
  bool first = true;
  late MapDataProvider obj;
  bool loading = true;

  void getData() async {
    obj = Provider.of<MapDataProvider>(context, listen: false);
    bool l = await obj.loadData();
    if (l && mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (first) {
      first = false;
      getData();
    }

    final String selectedCategory =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? "Electrician";

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: loading
          ? const Center(
              child: CupertinoActivityIndicator(radius: 16),
            )
          : MapBody(obj, selectedCategory: selectedCategory),
    );
  }
}

class MapBody extends StatefulWidget {
  final MapDataProvider obj;
  final String selectedCategory;

  const MapBody(this.obj, {Key? key, required this.selectedCategory})
      : super(key: key);

  @override
  _MapBodyState createState() => _MapBodyState();
}

class _MapBodyState extends State<MapBody> {
  late MapDataProvider obj;
  final PanelController _pc = PanelController();

  final MapType _mapType = MapType.normal;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(26.1445, 91.7362),
    zoom: 14.0,
  );

  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  @override
  void initState() {
    super.initState();
    obj = widget.obj;
  }

  @override
  Widget build(BuildContext context) {
    void _onMapCreated(GoogleMapController controller) {
      for (int i = 0; i < obj.mapDataList.length; i++) {
        final MarkerId markerId = MarkerId((markers.length + 1).toString());
        List cd = obj.mapDataList[i].location.split(",");
        LatLng markerPos = LatLng(
            double.tryParse(cd[0]) ?? 26.1445, double.tryParse(cd[1]) ?? 91.7362);
        final Marker marker = Marker(
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            markerId: markerId,
            infoWindow: InfoWindow(
              title: "${widget.selectedCategory} Expert ${i + 1}",
              snippet: "Rating: ${obj.mapDataList[i].rating}",
            ),
            position: markerPos);
        markers[markerId] = marker;
      }
      setState(() {});
    }

    return SlidingUpPanel(
      controller: _pc,
      color: const Color(0xFF1E293B),
      backdropEnabled: true,
      backdropColor: Colors.black,
      backdropOpacity: 0.4,
      maxHeight: 450,
      borderRadius: radius,
      collapsed: InkWell(
        onTap: () => _pc.open(),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(24.0),
              topLeft: Radius.circular(24.0),
            ),
            color: Color(0xFF1E293B),
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.orangeAccent,
                      size: 26,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Nearby Experts List",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "${obj.mapDataList.length} ${widget.selectedCategory} available in Assam",
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      panel: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Nearby ${widget.selectedCategory}s",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Showing Live",
                  style: TextStyle(color: Colors.greenAccent[400], fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: obj.mapDataList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (BuildContext ctxt, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/appointmentScreen',
                      arguments: widget.selectedCategory,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                          child: const Icon(Icons.person, color: Colors.orangeAccent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "${widget.selectedCategory} Partner ${index + 1}",
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Guwahati, Assam',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  obj.mapDataList[index].rating.toString(),
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "View Rates",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapToolbarEnabled: false,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            mapType: _mapType,
            markers: Set<Marker>.of(markers.values),
            initialCameraPosition: _kInitialPosition,
            onMapCreated: _onMapCreated,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1E293B),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: Text(
                        "Showing ${widget.selectedCategory}s in Assam",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

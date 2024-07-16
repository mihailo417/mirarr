import 'package:Mirarr/functions/show_error_dialog.dart';
import 'package:Mirarr/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> _launchUrl(Uri url) async {
  if (await canLaunchUrlString(url.toString())) {
    await launchUrlString(url.toString());
  } else {
    throw Exception('Could not launch url');
  }
}

void showWatchOptions(
    BuildContext context, int serieId, int seasonNumber, int episodeNumber) {
  Map<String, String> optionUrls = {
    'braflix':
        'https://www.braflix.video/movie/$serieId/$seasonNumber/$episodeNumber?play=true',
    'binged':
        'https://binged.live/watch/tv/$serieId?season=$seasonNumber&ep=$episodeNumber',
    'lonelil':
        'https://watch.lonelil.ru/watch/show/$serieId.$seasonNumber.$episodeNumber',
    'rive':
        'https://rivestream.live/watch?type=tv&id=$serieId&season=$seasonNumber&episode=$episodeNumber'
  };
  List<String> options = optionUrls.keys.toList();

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              'These are providers for the movie, choose one of them to play from that source',
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 16),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const CustomDivider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      String option = options[index];
                      String? url =
                          optionUrls[option]; // Retrieve URL for the option
                      return ListTile(
                        leading: Icon(Icons.play_arrow,
                            color: Theme.of(context).primaryColor),
                        title: Text(
                          option,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          if (url != null) {
                            // If URL is available, launch it
                            _launchUrl(Uri.parse(url));
                          } else {
                            // Handle case where URL is not available
                            showErrorDialog('Error',
                                'URL not available for $option', context);
                          }
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

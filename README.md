# Instructions

## You will need

- Wireshark
  - I used the bundled command line program `tshark`, but the same should be achievable using the graphical version as well
- Love Live! School Idol Festival on an Android device
  - I've only tested this on Android, I'm not sure if it'll work on iOS
- A PC or Mac with the ability to share a Wi-Fi network
  - It'll need to connect to the Internet through another means (e.g. an Ethernet cable) to leave the Wi-Fi free to share with the Android device

## Steps

- Enable Internet Sharing on your PC or Mac, and connect your Android device to the PC's network
  - On macOS, this is in `System Preferences > Sharing > Internet Sharing`
- Start up Wireshark, connect to the interface that corresponds to the Android device, and start capturing packets
  - In my case, the interface was called *`ap1`*, but YMMV
- Open up LLSIF on your Android device, and click through to the home screen
- Wireshark should now have a bunch of packets displayed. In the Filter bar, filter the packets with `json`
- You should see a bunch of HTTP/JSON requests to http://prod-jp.lovelive.ge.klabgames.net/. Make a note of the *`Destination IP address`*
  - In my case, the destination IP address was *`192.168.2.2`*
- Stop capturing packets in Wireshark, and close LLSIF
- Re-open LLSIF, but on the splash screen click the `Clear Cache` button, press OK/continue
  - The app will now clear out its caches and restart
  - Let it progress to the splash screen after restarting before continuing
- Run the command below
  - Remember to replace *`ap1`* and *`192.168.2.2`*

```
mkdir -p llsifwake/jsonfiles
cd llsifwake
path/to/tshark -i ap1 -f "dst host 192.168.2.2" -w outfile.pcapng --export-objects http,jsonfiles
```

- This starts capturing packets. Now press the LLSIF splash screen and let it download/fetch everything it needs.
  - The Standard download should be sufficient rather than the Full download
- Once LLSIF starts up, go to `Members > Member List`, and slowly scroll through the list
- Now go to the `Support` tag and do the same
- Now go to the `Waiting Room` and do the same
  - I'm not actually sure if these parts are required, but I did them just in case
- Now go back to the home screen, click `Presents`, and select the `Members` tab
- Start scrolling down the presents list, letting the next few presents load each time you reach the bottom
  - Continue until you can't scroll the list any more
- Once you've done this, on the window where you're running `tshark` hit `Ctrl-C` to stop the packet capture
  - The `jsonfiles` directory in there should now have a whole bunch of JSON files captured, in which your entire LLSIF history is buried
  - (It should also have a bunch of binary files, but these are ciphered by Klab and most likely not usable)

## Notes

The JSON files contain a lot of guff, so to find relevant stuff I used a few commands to filter out unnecessary files.

```
cd jsonfiles

# Lists the JSON files in creation time order
ls -lU *json | less

# There are a whole bunch of JSON files that only have request URLs for static assets. This command should filter those ones out
ls -U *json |xargs -I{} grep -L "{\"response_data\":{\"url_list\":" {} |less
```


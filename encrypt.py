import sys
from wannacri.usm import Usm, OpMode, generate_keys

def main():
    usm = Usm.open(sys.argv[1] + "/input-video.usm")
    # Refer to https://github.com/vgmstream/vgmstream/blob/master/src/meta/hca_keys.h (Line 1177 in the comment not the code)
    usmkey = 0x0074FF1FCE264700
    with open(sys.argv[1] + "/video.enc", "wb") as out:
        usm.video_key, usm.audio_key = generate_keys(usmkey)
        for packet in usm.stream(OpMode.ENCRYPT):
            out.write(packet)

if __name__ == "__main__":
    main()
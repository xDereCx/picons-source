So you would like to contribute? Below are some guidelines to follow.

ISSUES
======

When submitting an issue, make sure you follow these rules:

- New entries to `srindex`, copy/paste them here as inline code blocks ([help](https://guides.github.com/features/mastering-markdown)) or if they are really big, use [pastebin](http://pastebin.com)
- New logos can be put in an archive, correctly named (see below) and share the link here

NAMING
======

__Serviceref:__

- UPPERCASE
- Only the part `296_5_85_C00000` is used, the parts `1_0_1_` and `_0_0_0` must be removed

__Logo:__

- LOWERCASE
- NO spaces, fancy symbols or `.-+_`, except for the exceptions below
- Time sharing channels are seperated by `_`
- Sometimes it's useful to add a country code, do it by putting `-gbr`, `-deu` or `-...` at the end of the name. Country codes can be found [here](http://wikipedia.org/wiki/ISO_3166-1)
- If the channelname contains a `+`, use `+`, if it's a timeshift channel, use `plus1`
- Filetype `svg` is the way to go, otherwise `png`
- The resolution doesn't matter for `svg`, for `png` try to get it > 400px
- Quality should be as high as possible with transparancy
- A `white` version of a logo, should be placed in the folder `./build-source/tv/white` or `./build-source/radio/white`, a `black` version must always exist, a `white` version is optional
- Don't forget to put `tv/` or `radio/` in front of the logo's name in `./build-source/srindex`

SAMPLE OF SRINDEX
=================

New additions can go at the top. No need to cleanup old entries, but if you want to, go right ahead.

```
1005_29_46_E080000=tv/eurosporthd
1006_29_46_E080000=tv/discoveryhdshowcase
1007_43_46_E080000=tv/tvnorgehd
1008_29_46_E080000=tv/bbchd
100E_3_1_E083163=tv/viasat6
1015_1D4C_FBFF_820000=tv/discoveryhd
1018_1D4C_FBFF_820000=tv/cielohd
1018_3_1_E083163=tv/novacinema
10_1_85_C00000=tv/fox
10_1_85_FFFF0000=tv/fox
1019_7DC_2_11A0000=tv/skymoviesboxoffice-gbr
1019_7EF_2_11A0000=tv/skymoviesboxoffice-gbr
101B_7DC_2_11A0000=tv/skymoviesboxoffice-gbr
101B_7EF_2_11A0000=tv/skymoviesboxoffice-gbr
101_E_85_C00000=tv/skybundesligahd-deu
```
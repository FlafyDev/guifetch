# Guifetch
A GUI fetch tool written in Flutter.



https://user-images.githubusercontent.com/44374434/194888240-ec09ead1-2c5f-4773-90d9-c229e0e48e3e.mp4



## Development
Works, but you'll probably want to edit the `lib/info.dart` file for information to be correct like `neofetch`. (If you do so, please PR)

## Config
Located at `~/.config/guifetch/guifetch.toml`.
- `background_color` = Background color : `0xAARRGGBB`
- `os_id` = Which os id's image to display : `string`
- `os_image` = Override the image with an absolute path to an image file : `string`

## Building
1. Install Flutter
2. Clone this repository and cd into it
3. Run `flutter build linux --release`
4. Launch the executable generated in `./build/linux/x64/release/bundle/guifetch`

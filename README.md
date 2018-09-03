# Corona-OneSignal-Example
Corona and OneSignal example using REST API requests. 

Instructions to use in your own project.
1. Create an account and app in OneSignal.
2. Follow the instructions here to set up Corona Notification: https://docs.coronalabs.com/plugin/notifications-v2/index.html. 
3. Copy and past notification.lua file from this repo to your project.
4. Require the file at the top of your page:
```lua
local notify = require( "notification" )
```
5. Initialize the library. 
```lua
notify.init(
notifyListerner, --- Listerner you want to recieve the events.
  {
      appId = "", -- AppId from One Signal
      language = "en", -- Language. I use the candlelight plugin to get this, but you can also use "os.*" library.
      sessions = 23 -- I grab this from gamespark in my game but you can use a local variable you increment for every time they launch the app.
  }
) 
```
6. iOS example:
```json
Resposne: 	{
  "data":{
    "name":"notification",
    "type":"remote",
    "iosPayload": {..},
    "sound":"default",
    "alert":"hi. Hope you are doing well.",
    "applicationState":"inactive"
  },
  "name":"notify",
  "type":"remote"
}
```
8. Android example:
```json
Resposne: 	{
  "data":{
    "name":"notification",
    "type":"remote",
    "androidPayload": {..},
    "sound":"default",
    "alert":"hi. Hope you are doing well.",
    "applicationState":"inactive"
  },
  "name":"notify",
  "type":"remote"
}
```

Please note:
1. The notification icons I created and you can reuse them if you want. I just drew a star in the middle of the appropiate sized image.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


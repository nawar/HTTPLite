<p align="center">
<img src="https://cloud.githubusercontent.com/assets/928095/21403346/c7b6ea90-c792-11e6-9c3b-a7553268efd0.png" width="320">
</p>
# HTTPLite
A simple Swift 3.x wrapper for **URLSession**


[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/hyperium/hyper/master/LICENSE) ![ios/osx](https://cocoapod-badges.herokuapp.com/p/AFNetworking/badge.png)

## Usuage 

To use the wrapper, a simple declration of a `Request` object suffices, with the recipent URL.

```swift
guard let request = Request(Url: "https://www.google.com") else {
    print("Can't intialize the request")
    return
}
```

After that, we can peform any HTTP verb.

### GET

```swift
let params: [String: String] = ["Artist" : "Michael Jackson", "Album" : "Thriller"]

request.get(parameters: params, success: { response in

    if let data = response.data {
    }

    if let url = response.url {

    }

}, failure: { error in

}) { progress in

}
```

#### JSON handling

```swift
let params: [String: String] = ["album" : "Michael Jackson - Thriller"]

request.get(parameters: params, success: { response in

    if let data = response.data {

   	do {
       		 let JSON = try JSONSerialization.jsonObject(with: data,
       		 options: .mutableContainers)
    	
	} catch let error {	
        }
    }

    if let url = response.url { }

}, failure: { error in

}, progress: { progress in

})
```

### POST
```swift
let params: [String: String] = ["healer":"Grigori Yefimovich Rasputin", "powers": "healer and adviser"]

request.post(parameters: params, success: { response in

    print("response data:\(response)")

}, failure: { error in

}, progress: { progress in

})

```

### Download

We can download files using either `download()` or `get()`.

#### Download with `get()`

```swift
let params: [String: String] = ["image":"to be downloaded as data"]

request.get(parameters: params, success: { response in

    if let data = response.data { 
        let image = UIImage(data: data)
    }

    if let url = response.url { }

}, failure: { error in

}, progress: { progress in

})
```

#### Download with `download()`

```swift
let params: [String: String] = ["image":"to be downloaded as one file"]

request.download(parameters: params, success: { response in

    if let data = response.data { }

    if let url = response.url { 
        let image = UIImage(contentsOfFile: url.path)
    }

}, failure: { error in

}, progress: { progress in

})
```

##### Download Progress

We can easily measure the progress of a file download using the `progress` closure. 

```swift
let params: [String: String] = ["image":"to be downloaded as one file with progress"]

request.download(parameters: params, success: { response in

    if let data = response.data { }

    if let url = response.url { 
        let image = UIImage(contentsOfFile: url.path)
    }

}, failure: { error in

}, progress: { progress in

	print("Download progress \(progress)")

})
```

## Installation 

### CocoaPods

To install, check out Get Started tab on cocoapods.org.
To use HTTPLite in your project add the pod below to your project's `Podfile` 

```
pod 'HTTPLite'
```

Then, from the command line, run:

```
pod install # or pod update
```
Then you are good to go :+1:

# HTTPLite
A simple Swift 3.x wrapper for URLSession


[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/hyperium/hyper/master/LICENSE)

![ios/osx](https://cocoapod-badges.herokuapp.com/p/AFNetworking/badge.png)

## Usuage 

To use the wrapper, a simple declration of a `Request` object suffices, with the recipent URL.

```swift
guard let request = Request(Url: "https://www.google.com") else {
    fatalError("Can't intialize the request")
    return
}
```

After that, we can peform any HTTP verb.

### GET

```swift

let params: [String: String] = ["album":"Michael Jackson - Thriller"]

request.GET(parameters: params, success: { response, url in

    if let urlReponse = url {
        print("success with url:\(urlReponse)")
    }

    print("response data:\(response)")

}, failure: { error in

    print("error happend in failure closure")

}, progress: { progress in

    if progress > 0 {
        print("progress: \(progress)")
    }

})

```

### POST
```swift

let params: [String: String] = ["healer":"Grigori Yefimovich Rasputin", "powers": "healer and adviser"]

request.POST(parameters: params, success: { response, url in

    if let urlReponse = url {
        print("success with url:\(urlReponse)")
    }

    print("response data:\(response)")

}, failure: { error in

    print("error happend in failure closure")
    XCTFail("error: \(error.localizedDescription)")

}, progress: { progress in

    if progress > 0 {
        print("progress: \(progress)")
    }

})

```

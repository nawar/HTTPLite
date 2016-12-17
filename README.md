# HTTPLite
A simple Swift 3.x wrapper for URLSession


[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/hyperium/hyper/master/LICENSE)


## Usuage 

To use the wrapper a simple declration for the `Request` object suffices, followed by the type of the request that we are intendeing to send.

```swift
guard let request = Request(Url: "https://www.google.com") else {
    fatalError("Can't intialize the request")
    return
}
```

Then we can peform any HTTP verb:

### POST

```swift

let params: [String: Any] = [:]
request.POST(parameters: params, success: { response, url in

    if let urlReponse = url {
        print("success to url:\(urlReponse)")
    }

    print("response data:\(response)")

}, failure: { error in

    print("error happend in filure closure")

}, progress: { progress in

    print("progress:\(progress)")

})
```

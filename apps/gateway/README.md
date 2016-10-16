# Gateway

**Multiport forward proxy by policies.**

**Heavily inspired by KazuCocoa's [http_proxy](https://github.com/KazuCocoa/http_proxy).**

##Configuration

GATEWAY host = xyz

```
admin : localhost:4000
```

```
#map hosts/port

%{ railsapp: %{
     in: "localhost:8088",
     location: "localhost:3000",
     routes: %{
       "/bar/*": :pass_through,
       "/foo/*": :protected
     },
   },
   nodeapp: %{
     in: "localhost:8078",
     location: "localhost:5000",
     routes: %{
       "/abc/*": :pass_through,
       "/xyz/*": :protected
     }
   }
}
```






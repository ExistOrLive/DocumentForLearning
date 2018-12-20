# CALAyer

>  一个管理基于图像内容并允许你在内容上执行动画的对象(An object that manages image-based content and allows you to perform animations on that content)
----

## Overview

> `CALayer` 经常作为视图`UIView`的后备存储（the backing store），同时也可以单独用于显示内容。`CALayer`的主要工作是管理你提供的画面，也有一些画面相关的属性可以设置，例如background color，border和shadow。为了管理画面，`CALayer`维护了一些内容的几何信息（position，size和transform）。修改`CALayer`的属性就是启动一个基于内容和几何信息的动画。`CALayer`通过继承`CAMediaTiming`协议封装（ancapsulates）时延和bu
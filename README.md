# salesforce-Multiple-to-Multiple-Select 
# salesforce 多对多 选项列表


//中文版本说明 

salesforce 不支持多对多 选项列表的依赖性设置，仅仅支持 一对一 或 一对多的选项列表。但在项目实施过程中，总有实际业务场景会涉及到该场景。
所以边做了此公共组件，方便后续碰到该问题可复用。

首先我们创建一个对象， 新建四个选项列表字段 。 如下图， 三个多选列表， 一个单选列表。

即 展示用父列表（多选） 展示用子列表（多选）
  依赖关系父列表（单选） 依赖关系子列表（多选）

//english
salesforce is not support multiple to multiple Dependencies select . 
Only support single to multiple || single to single select . 

WE created four fields . and two fields is use for jst logic. To get the Dependencies .
And the other fiedls use for show on the record page . 

![image](https://github.com/RosingL/salesforce-Multiple-to-Multiple-Select/blob/master/Images/FieldCreated.png)

配置好依赖关系。


![image](https://github.com/RosingL/salesforce-Multiple-to-Multiple-Select/blob/master/Images/FieldDependencies.png)

![image](https://github.com/RosingL/salesforce-Multiple-to-Multiple-Select/blob/master/Images/FieldDepend.png)
通过代码读取依赖关系，会自动将选项列表值LABEL及依赖关系自动带出。  展示出多对多选择的效果。 
最终展示效果如图 
保存的值，存入展示用的两个选项列表字段， 并在页面布局放出来。


![image](https://github.com/RosingL/salesforce-Multiple-to-Multiple-Select/blob/master/Images/showResult.png)
![image](https://github.com/RosingL/salesforce-Multiple-to-Multiple-Select/blob/master/Images/Save.png)

Notice:需要在Aura Component中引用jquery 。 jquery文件已经上传。
Notice: Need Using Jquery in component.  jquery Fild is uploaded.

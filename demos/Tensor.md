<!--
author:   Your Name

email:    your@mail.org

version:  0.0.1

language: en

narrator: US English Female

comment:  Try to write a short comment about
          your course, multiline is also okay.

script:   https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@0.13.3/dist/tf.min.js

script:  https://cdnjs.cloudflare.com/ajax/libs/echarts/4.1.0/echarts-en.min.js


@eval
<script>
function reportError(error) {
   let line = getLineNumber(error);
   let details = [];
   let msg = "An error occured";

  if (line) {
    details = [[{ row : line-1,
               column : 0,
                 text : error.message,
                 type : "error" }]];

    msg += " on line " + line;
  }
  send.lia("eval", msg + "\n" + error.message, details, false);
};

async function eee(code) {
  let oldLog = console.log;

  console.log = function(e){ send.lia("output", e + "\n") };

  try {
    const evalString = '(async function runner() { try { ' + code + '} catch (e) { reportError(e) } })()';

    await eval(evalString).catch(function(e) {
      reportError(e);
      console.log = oldLog;
    });
    send.lia("eval", "LIA: stop");
  }
  catch(e) {
    console.log = oldLog;
    reportError(e);
  }
};
setTimeout(function(e){ eee(`@input`+"\n") }, 100);
"LIA: wait";
</script>
@end


@eval2
<script>
function reportError(error) {
   let line = getLineNumber(error);
   let details = [];
   let msg = "An error occured";

  if (line) {
    details = [[{ row : line-1,
               column : 0,
                 text : error.message,
                 type : "error" }]];

    msg += " on line " + line;
  }
  send.lia("eval", msg + "\n" + error.message, details, false);
};

async function eee() {
  let file1 = `@input(0)` + "\n";
  let file2 = `@input(1)` + "\n";
  let oldLog = console.log;

  console.log = function(e){ send.lia("output", e + "\n") };

  try {
    const evalString = '(async function runner() { try { ' + file1 + file2 + '} catch (e) { reportError(e) } })()';

    await eval(evalString).catch(function(e) {
      reportError(e);
      console.log = oldLog;
    });
    send.lia("eval", "LIA: stop");
  }
  catch(e) {
    console.log = oldLog;
    reportError(e);
  }
};
setTimeout(function(e){ eee(`@input`+"\n") }, 100);
"LIA: wait";
</script>
@end


-->

# TensorFlow.js

## Core Concepts

__TensorFlow.js__ is an open source WebGL-accelerated JavaScript library for
machine intelligence. It brings highly performant machine learning building
blocks to your fingertips, allowing you to train neural networks in a browser or
run pre-trained models in inference mode. See
[Getting Started](https://js.tensorflow.org/index.html#getting-started)
for a guide on installing/configuring TensorFlow.js.

TensorFlow.js provides low-level building blocks for machine learning as well as
a high-level, Keras-inspired API for constructing neural networks. Let's take a
look at some of the core components of the library.

[chap](#4)

### Tensors

The central unit of data in TensorFlow.js is the tensor: a set of numerical
values shaped into an array of one or more dimensions. A
[`Tensor`](https://js.tensorflow.org/api/latest/index.html#class:Tensor) instance
has a `shape` attribute that defines the array shape (i.e., how many values are
in each dimension of the array).

The primary `Tensor` constructor is the
[`tf.tensor`](https://js.tensorflow.org/api/latest/index.html#tensor)
function:

``` javascript
// 2x3 Tensor
const shape = [2, 3]; // 2 rows, 3 columns
const a = tf.tensor([1.0, 2.0, 3.0, 10.0, 20.0, 30.0], shape);
a.print(); // print Tensor values

// The shape can also be inferred:
const b = tf.tensor([[1.0, 2.0, 3.0], [10.0, 20.0, 30.0]]);
b.print(); // print Tensor values
```
@eval


<!-- hidden="true" -->
```
Output: [[1 , 2 , 3 ],
         [10, 20, 30]]

Output: [[1 , 2 , 3 ],
         [10, 20, 30]]
```

However, for constructing low-rank tensors, we recommend using the following
functions to enhance code readability:
[`tf.scalar`](https://js.tensorflow.org/api/latest/index.html#scalar),
[`tf.tensor1d`](https://js.tensorflow.org/api/latest/index.html#tensor1d),
[`tf.tensor2d`](https://js.tensorflow.org/api/latest/index.html#tensor2d),
[`tf.tensor3d`](https://js.tensorflow.org/api/latest/index.html#tensor3d) and
[`tf.tensor4d`](https://js.tensorflow.org/api/latest/index.html#tensor4d).

The following example creates an identical tensor to the one above using
`tf.tensor2d`:

``` javascript
const c = tf.tensor2d([[1.0, 2.0, 3.0], [10.0, 20.0, 30.0]]);
c.print();
```
@eval


<!-- hidden="true" -->
```
Output: [[1 , 2 , 3 ],
         [10, 20, 30]]

Output: [[1 , 2 , 3 ],
         [10, 20, 30]]
```

TensorFlow.js also provides convenience functions for creating tensors with all
values set to 0
([`tf.zeros`](https://js.tensorflow.org/api/latest/index.html#zeros)) or all
values set to 1
([`tf.ones`](https://js.tensorflow.org/api/latest/index.html#ones)):

``` javascript
// 3x5 Tensor with all values set to 0
const zeros = tf.zeros([3, 5]);
zeros.print();
// Output: [[0, 0, 0, 0, 0],
//          [0, 0, 0, 0, 0],
//          [0, 0, 0, 0, 0]]

```
@eval

In TensorFlow.js, tensors are immutable; once created, you cannot change their
values. Instead you perform operations on them that generate new tensors.


### Variables

[`Variable`s](https://js.tensorflow.org/api/latest/index.html#class:Variable)
are initialized with a tensor of values. Unlike `Tensor`s, however, their values
are mutable. You can `assign` a new tensor to an existing variable using the
assign method:

```javascript
const initialValues = tf.zeros([5]);
const biases = tf.variable(initialValues); // initialize biases
biases.print();                            // output: [0, 0, 0, 0, 0]

const updatedValues = tf.tensor1d([0, 1, 0, 1, 0]);
biases.assign(updatedValues); // update values of biases
biases.print();               // output: [0, 1, 0, 1, 0]
```
@eval

Variables are primarily used to store and then update values during model
training.


### Operations (Ops)

While tensors allow you to store data, operations (ops) allow you to manipulate
that data. TensorFlow.js provides a wide variety of ops suitable for linear
algebra and machine learning that can be performed on tensors. Because tensors
are immutable, these ops do not change their values; instead, ops return new
tensors.

Available ops include unary ops such as
[`square`](https://js.tensorflow.org/api/latest/index.html#square):

```javascript
const d = tf.tensor2d([[1.0, 2.0], [3.0, 4.0]]);
const d_squared = d.square();
d_squared.print();
// Output: [[1, 4 ],
//          [9, 16]]
```
@eval

And binary ops such as
[`add`](https://js.tensorflow.org/api/latest/index.html#add),
[`sub`](https://js.tensorflow.org/api/latest/index.html#sub), and
[`mul`](https://js.tensorflow.org/api/latest/index.html#mull):

```javascript
const e = tf.tensor2d([[1.0, 2.0], [3.0, 4.0]]);
const f = tf.tensor2d([[5.0, 6.0], [7.0, 8.0]]);

const e_plus_f = e.add(f);
e_plus_f.print();
// Output: [[6 , 8 ],
//          [10, 12]]
```
@eval

TensorFlow.js has a chainable API; you can call ops on the result of ops:

```javascript
const e = tf.tensor2d([[1.0, 2.0], [3.0, 4.0]]);
const f = tf.tensor2d([[5.0, 6.0], [7.0, 8.0]]);

const sq_sum = e.add(f).square();
sq_sum.print();
// Output: [[36 , 64 ],
//          [100, 144]]
```
@eval

All operations are also exposed as functions in the main namespace, so you could
also do the following:

```javascript
const e = tf.tensor2d([[1.0, 2.0], [3.0, 4.0]]);
const f = tf.tensor2d([[5.0, 6.0], [7.0, 8.0]]);

const sq_sum = tf.square(tf.add(e, f));
sq_sum.print();
```
@eval

### Models and Layers

Conceptually, a model is a function that given some input will produce some
desired output.

In TensorFlow.js there are _two ways_ to create models. You can
_use ops directly_ to represent the work the model does. For example:

```javascript
// Define function
function predict(input) {
  // y = a * x ^ 2 + b * x + c
  // More on tf.tidy in the next section
  return tf.tidy(() => {
    const x = tf.scalar(input);

    const ax2 = a.mul(x.square());
    const bx = b.mul(x);
    const y = ax2.add(bx).add(c);

    return y;
  });
}

// Define constants: y = 2x^2 + 4x + 8
const a = tf.scalar(2);
const b = tf.scalar(4);
const c = tf.scalar(8);

// Predict output for input of 2
const result = predict(2);
result.print() // Output: 24
```
@eval

You can also use the high-level API
[`tf.model`](https://js.tensorflow.org/api/latest/index.html#model) to construct
a model out of _layers_, which are a popular abstraction in deep learning. The
following code constructs a
[`tf.sequential`](https://js.tensorflow.org/api/latest/index.html#sequential)
model:

```javascript
const model = tf.sequential();
model.add(
  tf.layers.simpleRNN({
    units: 20,
    recurrentInitializer: 'GlorotNormal',
    inputShape: [80, 4]
  })
);

const optimizer = tf.train.sgd(LEARNING_RATE);
model.compile({optimizer, loss: 'categoricalCrossentropy'});
model.fit({x: data, y: labels});
```

There are many different types of layers available in TensorFlow.js. A few
examples include
[`tf.layers.simpleRNN`](https://js.tensorflow.org/api/latest/index.html#layers.simpleRNN),
[`tf.layers.gru`](https://js.tensorflow.org/api/latest/index.html#layers.gru),
and
[`tf.layers.lstm`](https://js.tensorflow.org/api/latest/index.html#layers.lstm).

### Memory Management: `dispose` and `tf.tidy`

Because TensorFlow.js uses the GPU to accelerate math operations, it's necessary
to manage GPU memory when working with tensors and variables.

TensorFlow.js provide two functions to help with this: `dispose` and
[`tf.tidy`](https://js.tensorflow.org/api/latest/index.html#tidy).

#### `dispose`

You can call dispose on a tensor or variable to purge it and free up its GPU
memory:

```javascript
const x = tf.tensor2d([[0.0, 2.0], [4.0, 6.0]]);
const x_squared = x.square();

x.dispose();
x_squared.dispose();

x.print()         // will create an Error (Tensor is disposed)
x_squared.print() // ...
```
@eval

#### `tf.tidy`

Using `dispose` can be cumbersome when doing a lot of tensor operations.
TensorFlow.js provides another function, `tf.tidy`, that plays a similar role to
regular scopes in JavaScript, but for GPU-backed tensors.

`tf.tidy` executes a function and purges any intermediate tensors created,
freeing up their GPU memory. It does not purge the return value of the inner
function.

```javascript
// tf.tidy takes a function to tidy up after
const average = tf.tidy(() => {
  // tf.tidy will clean up all the GPU memory used by tensors inside
  // this function, other than the tensor that is returned.
  //
  // Even in a short sequence of operations like the one below, a number
  // of intermediate tensors get created. So it is a good practice to
  // put your math ops in a tidy!
  const y = tf.tensor1d([1.0, 2.0, 3.0, 4.0]);
  const z = tf.ones([4]);

  return y.sub(z).square().mean();
});

average.print() // Output: 3.5
```
@eval

Using `tf.tidy` will help prevent memory leaks in your application. It can also
be used to more carefully control when memory is reclaimed.

__Two important notes__

* The function passed to `tf.tidy` should be synchronous and also not return a
  Promise. We suggest keeping code that updates the UI or makes remote requests
  outside of `tf.tidy`.
* `tf.tidy` _will not_ clean up variables. Variables typically last through the
  entire lifecycle of a machine learning model, so TensorFlow.js doesn't clean
  them up even if they are created in a `tidy`; however, you can call `dispose`
  on them manually.

### Additional Resources

See the
[TensorFlow.js API reference](https://js.tensorflow.org/api/latest/index.html)
for comprehensive documentation of the library.

For a more in-depth look at machine learning fundamentals, see the following
resources:

* [Machine Learning Crash Course](https://developers.google.com/machine-learning/crash-course)
  (Note: this course's exercises use TensorFlow's
  [Python API](https://www.tensorflow.org/api_docs/python/).
  However, the core machine learning concepts it teaches can be applied in
  equivalent fashion using TensorFlow.js.)
* [Machine Learning Glossary](https://developers.google.com/machine-learning/glossary)


## Training First Steps: Fitting a Curve to Synthetic Data

In this tutorial, we'll use TensorFlow.js to fit a curve to a synthetic dataset.
Given some data generated using a polynomial function with some noise added,
we'll train a model to discover the coefficients used to generate the data.

__Prerequisites__

This tutorial assumes familiarity with the fundamental building blocks of
TensorFlow.js introduced in [Core Concepts](#2): tensors, variables, and ops. We
recommend completing Core Concepts before doing this tutorial.

__Running the Code__

TODO

### Input Data

Our synthetic data set is composed of x- and y-coordinates that look as follows
when plotted on a Cartesian plane:


```javascript data.js
window.generateData = function (numPoints, coeff, sigma = 0.04) {
  return tf.tidy(() => {
    const [a, b, c, d] = [
      tf.scalar(coeff.a), tf.scalar(coeff.b),
      tf.scalar(coeff.c), tf.scalar(coeff.d)];

    const xs = tf.randomUniform([numPoints], -1, 1);

    // Generate polynomial data
    const three = tf.scalar(3, 'int32');
    const ys = a.mul(xs.pow(three))
      .add(b.mul(xs.square()))
      .add(c.mul(xs))
      .add(d)
      // Add random noise to the generated data
      // to make the problem a bit more interesting
      .add(tf.randomNormal([numPoints], 0, sigma));

    // Normalize the y values to the range 0 to 1.
    const ymin = ys.min();
    const ymax = ys.max();
    const yrange = ymax.sub(ymin);
    const ysNormalized = ys.sub(ymin).div(yrange);

    return {
      xs,
      ys: ysNormalized
    };
  })
}
console.log("global function 'generateData' generated!")
```
@eval


This data was generated using a cubic function of the format
$y = ax3 + bx2 + cx + d$.

Our task is to learn the coefficients of this function: the values of $a$, $b$,
$c$, and $d$ that best fit the data. Let's take a look at how we might learn
those values using TensorFlow.js operations.


```javascript index.js
const trueCoefficients = {a: -.8, b: -.2, c: .9, d: .5};
window.trainingData = generateData(100, trueCoefficients);

plotData(trainingData.xs, trainingData.ys);
```
``` javascript -ui.js
async function plotData(xs, ys) {
	const xvals = await xs.data();
  const yvals = await ys.data();

  let main = document.getElementById('main');
  main.hidden = false;

  let chart = echarts.init(main);

  let values = Array.from(yvals).map((y, i) => {
     return [xvals[i], yvals[i]];
  });

  let c = trueCoefficients;

  let option = {
    title : {
      text: 'Original Data (Synthetic)',
      subtext: 'True coefficients: a='+c.a+", b="+c.b+", c="+c.c+", d="+c.d
    },
    toolbox: {
      show : true,
      feature : {
        mark : {show: true},
        dataZoom : {show: true},
        dataView : {show: true, readOnly: false},
        restore : {show: true},
        saveAsImage : {show: true}
      }
    },
    xAxis : [{
      type : 'value',
      scale: true,
      axisLabel : { formatter: '{value}' }
    }],
    yAxis : [{
      type : 'value',
      scale: true,
      axisLabel : { formatter: '{value}'}
    }],
    series : [{
      name: 'data',
      type: 'scatter',
      data: values,
    }]
  };

  // use configuration item and data specified to show chart
  chart.setOption(option);

  window.addEventListener('resize', chart.resize);
}
```
@eval2


<div id="main" class="persistent" style="position: relative; width:100%; height:400px;" hidden="true"></div>




### Step 1: Set up Variables

First, let's create some variables to hold our current best estimate of these
values at each step of model training. To start, we'll assign each of these
variables a random number:

```javascript
const a = tf.variable(tf.scalar(Math.random()));
const b = tf.variable(tf.scalar(Math.random()));
const c = tf.variable(tf.scalar(Math.random()));
const d = tf.variable(tf.scalar(Math.random()));

a.print(); b.print(); c.print(); d.print();

window.startVariables = [a, b, c, d];
```
@eval

### Step 2: Build a Model

We can represent our polynomial function $y = ax3 + bx2 + cx + d$ in
TensorFlow.js by chaining a series of mathematical operations: addition (`add`),
multiplication (`mul`), and exponentiation (`pow` and `square`).

The following code constructs a predict function that takes `x` as input and
returns `y`:

``` javascript predict.js
function predict(x) {
  let [a, b, c, d] = startVariables;
  // y = a * x ^ 3 + b * x ^ 2 + c * x + d
  return tf.tidy(() => {
    return a.mul(x.pow(tf.scalar(3))) // a * x^3
      .add(b.mul(x.square())) // + b * x ^ 2
      .add(c.mul(x)) // + c * x
      .add(d); // + d
  });
}

const prediction = predict(trainingData.xs);
plotData(trainingData.xs, trainingData.ys, prediction);
```
``` javascript -ui.js
async function plotData(xs, ys, ts) {

	const xvals = await xs.data();
  const yvals = await ys.data();
  const tvals = await ts.data();

  let main = document.getElementById('main2');
  main.hidden = false;

  let chart = echarts.init(main);

  let predictions = Array.from(yvals).map((y, i) => {
     return [xvals[i], tvals[i]];
  }).sort((a,b) => {
    return (a[0] < b[0] ? 1 : -1)
  });

  let values = Array.from(yvals).map((y, i) => {
     return [xvals[i], yvals[i]];
  });

  let [a, b, c, d] = startVariables;

  a = await a.data();
  b = await b.data();
  c = await c.data();
  d = await d.data();

  let option = {
    title : {
      text: 'Fit courve with random coefficients (before trainig)',
      subtext: "Random coefficient: a="+a+", b="+b+", c="+c+", d="+d
    },
    legend: {
        data: ['fuck', 'fuckking']
    },
    toolbox: {
      show : true,
      feature : {
        mark : {show: true},
        dataZoom : {show: true},
        dataView : {show: true, readOnly: false},
        restore : {show: true},
        saveAsImage : {show: true}
      }
    },
    xAxis : [{
      type : 'value',
      scale: true,
      axisLabel : { formatter: '{value}' }
    }],
    yAxis : [{
      type : 'value',
      scale: true,
      axisLabel : { formatter: '{value}'}
    }],
    series : [
      {name: 'trainig data', type: 'scatter', data: values },
      {name: 'prediction', type: 'line', data: predictions }
    ]
  };

  chart.setOption(option);
  window.addEventListener('resize', chart.resize);
}
```
@eval2

<div id="main2" class="persistent" style="position: relative; width:100%; height:400px;" hidden="true"></div>

Let's go ahead and plot our polynomial function using the random values for $a$,
$b$, $c$, and $d$ that we set in Step 1. Our plot will likely look something
like this:


Because we started with random values, our function is likely a very poor fit
for the data set. The model has yet to learn better values for the coefficients.

### Step 3: Train the Model

Our final step is to train the model to learn good values for the coefficients.
To train our model, we need to define three things:

* A _loss function_, which measures how well a given polynomial fits the data.
  The lower the loss value, the better the polynomial fits the data.
* An _optimizer_, which implements an algorithm for revising our coefficient
  values based on the output of the loss function. The optimizer's goal is to
  minimize the output value of the loss function.
* A _training loop_, which will iteratively run the optimizer to minimize loss.


#### Define the Loss Function

For this tutorial, we'll use
[mean squared error (MSE)](https://developers.google.com/machine-learning/crash-course/glossary/#MSE)
as our loss function. MSE is calculated by squaring the difference between the
actual $y$ value and the predicted $y$ value for each $x$ value in our data set,
and then taking the mean of all the resulting terms.

We can define a MSE loss function in TensorFlow.js as follows:

``` javascript
function loss(predictions, labels) {
  // Subtract our labels (actual values) from predictions, square the results,
  // and take the mean.
  const meanSquareError = predictions.sub(labels).square().mean();
  return meanSquareError;
}
```

#### Define the Optimizer

For our optimizer, we'll use
[Stochastic Gradient Descent](https://developers.google.com/machine-learning/crash-course/glossary#SGD)
(SGD). SGD works by
taking the
[gradient](https://developers.google.com/machine-learning/crash-course/glossary#gradient)
of a random point in our data set and using its value to
inform whether to increase or decrease the value of our model coefficients.

TensorFlow.js provides a convenience function for performing SGD, so that you
don't have to worry about performing all these mathematical operations yourself.
[`tf.train.sgd`](https://js.tensorflow.org/api/latest/index.html#train.sgd)
takes as input a desired _learning rate_, and returns an `SGDOptimizer` object,
which can be invoked to optimize the value of the loss function.

The learning rate controls how big the model's adjustments will be when
improving its predictions. A low learning rate will make the learning process
run more slowly (more training iterations needed to learn good coefficients),
while a high learning rate will speed up learning but might result in the model
oscillating around the right values, always overcorrecting.

The following code constructs an SGD optimizer with a learning rate of 0.5:

``` javascript
const learningRate = 0.5;
const optimizer = tf.train.sgd(learningRate);
```

#### Define the Training Loop

Now that we've defined our loss function and optimizer, we can build a training
loop, which iteratively performs SGD to refine our model's coefficients to
minimize loss (MSE). Here's what our loop looks like:

``` javascript
function train(xs, ys, numIterations = 75) {

  const learningRate = 0.5;
  const optimizer = tf.train.sgd(learningRate);

  for (let iter = 0; iter < numIterations; iter++) {
    optimizer.minimize(() => {
      const predsYs = predict(xs);
      return loss(predsYs, ys);
    });
  }
}
```

Let's take a closer look at the code, step by step. First, we define our
training function to take the _x_ and _y_ values of our dataset, as well as a
specified number of iterations, as input:

``` javascript
function train(xs, ys, numIterations) {
...
}
```

Next, we define the learning rate and SGD optimizer as discussed in the previous
section:

``` javascript
const learningRate = 0.5;
const optimizer = tf.train.sgd(learningRate);
```

Finally, we set up a `for` loop that runs `numIterations` training iterations.
In each iteration, we invoke
[`minimize`](https://js.tensorflow.org/api/latest/index.html#class:train.Optimizer)
on the optimizer, which is where the magic happens:

``` javascript
for (let iter = 0; iter < numIterations; iter++) {
  optimizer.minimize(() => {
    const predsYs = predict(xs);
    return loss(predsYs, ys);
  });
}
```

`minimize` takes a function that does two things:

1. It predicts y values (`predYs`) for all the _x_ values using the `predict`
   model function we defined earlier in Step 2.
2. It returns the mean squared error loss for those predictions using the loss
   function we defined earlier in __Define the Loss Function__.

`minimize` then automatically adjusts any `Variable`s used by this function
(here, the coefficients `a`, `b`, `c`, and `d`) in order to minimize the return
value (our loss).

After running our training loop, `a`, `b`, `c`, and `d` will contain the
coefficient values learned by the model after 75 iterations of SGD.

### See the Results!

Once the program finishes running, we can take the final values of our variables
`a`, `b`, `c`, and `d`, and use them to plot a curve:

```javascript
// Step 1. Set up variables, these are the things we want the model
// to learn in order to do prediction accurately. We will initialize
// them with random values.
const a = tf.variable(tf.scalar(Math.random()));
const b = tf.variable(tf.scalar(Math.random()));
const c = tf.variable(tf.scalar(Math.random()));
const d = tf.variable(tf.scalar(Math.random()));


// Step 2. Create an optimizer, we will use this later. You can play
// with some of these values to see how the model performs.
const numIterations = 75;
const learningRate = 0.5;
const optimizer = tf.train.sgd(learningRate);

// Step 3. Write our training process functions.
function predict(x) {
  // y = a * x ^ 3 + b * x ^ 2 + c * x + d
  return tf.tidy(() => {
    return a.mul(x.pow(tf.scalar(3, 'int32')))
      .add(b.mul(x.square()))
      .add(c.mul(x))
      .add(d);
  });
}

function loss(prediction, labels) {
  // Having a good error function is key for training a machine learning model
  const error = prediction.sub(labels).square().mean();
  return error;
}

async function train(xs, ys, numIterations) {
  for (let iter = 0; iter < numIterations; iter++) {
    optimizer.minimize(() => {
      // Feed the examples into the model
      const pred = predict(xs);
      return loss(pred, ys);
    });

    // Use tf.nextFrame to not block the browser.
    await tf.nextFrame();
  }
}

const trueCoefficients = {a: -.8, b: -.2, c: .9, d: .5};
//const trainingData = generateData(100, trueCoefficients);

trainingData.print();

// Plot original data
//  renderCoefficients('#data .coeff', trueCoefficients);
//  await plotData('#data .plot', trainingData.xs, trainingData.ys)


const predictionsBefore = predict(trainingData.xs);

// Train the model!
await train(trainingData.xs, trainingData.ys, numIterations);


const predictionsAfter = predict(trainingData.xs);

predictionsBefore.dispose();
predictionsAfter.dispose();
```
@eval


The result is much better than the curve we originally plotted using random
values for the coefficient.

### Additional Resources

* See [Core Concepts in TensorFlow.js](#2) for an introduction to the core
  building blocks in TensorFlow.js: tensors, variables, and ops.
* See
  [Descending into ML](https://developers.google.com/machine-learning/crash-course/descending-into-ml/)
  in
  [Machine Learning](https://developers.google.com/machine-learning/crash-course/)
  Crash Course for a more in-depth introduction to machine learning loss
* See
  [Reducing  Loss](https://developers.google.com/machine-learning/crash-course/reducing-loss/)
  in
  [Machine Learning Crash   Course](https://developers.google.com/machine-learning/crash-course/)
  for a deeper dive into gradient descent and SGD.

## Training on Images

In this tutorial, we'll build a TensorFlow.js model to classify handwritten
digits with a convolutional neural network. First, we'll train the classifier by
having it “look” at thousands of handwritten digit images and their labels. Then
we'll evaluate the classifier's accuracy using test data that the model has
never seen.

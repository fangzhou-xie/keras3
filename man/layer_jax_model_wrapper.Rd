% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/layers-backend-wrappers.R
\name{layer_jax_model_wrapper}
\alias{layer_jax_model_wrapper}
\title{Keras Layer that wraps a JAX model.}
\usage{
layer_jax_model_wrapper(
  object,
  call_fn,
  init_fn = NULL,
  params = NULL,
  state = NULL,
  seed = NULL,
  ...,
  dtype = NULL
)
}
\arguments{
\item{object}{Object to compose the layer with. A tensor, array, or sequential model.}

\item{call_fn}{The function to call the model. See description above for the
list of arguments it takes and the outputs it returns.}

\item{init_fn}{the function to call to initialize the model. See description
above for the list of arguments it takes and the outputs it returns.
If \code{NULL}, then \code{params} and/or \code{state} must be provided.}

\item{params}{A \code{PyTree} containing all the model trainable parameters. This
allows passing trained parameters or controlling the initialization.
If both \code{params} and \code{state} are \code{NULL}, \code{init_fn()} is called at
build time to initialize the trainable parameters of the model.}

\item{state}{A \code{PyTree} containing all the model non-trainable state. This
allows passing learned state or controlling the initialization. If
both \code{params} and \code{state} are \code{NULL}, and \code{call_fn()} takes a \code{state}
argument, then \code{init_fn()} is called at build time to initialize the
non-trainable state of the model.}

\item{seed}{Seed for random number generator. Optional.}

\item{...}{For forward/backward compatability.}

\item{dtype}{The dtype of the layer's computations and weights. Can also be a
\code{keras.DTypePolicy}. Optional. Defaults to the default policy.}
}
\value{
The return value depends on the value provided for the first argument.
If  \code{object} is:
\itemize{
\item a \code{keras_model_sequential()}, then the layer is added to the sequential model
(which is modified in place). To enable piping, the sequential model is also
returned, invisibly.
\item a \code{keras_input()}, then the output tensor from calling \code{layer(input)} is returned.
\item \code{NULL} or missing, then a \code{Layer} instance is returned.
}
}
\description{
This layer enables the use of JAX components within Keras when using JAX as
the backend for Keras.
}
\section{Model function}{
This layer accepts JAX models in the form of a function, \code{call_fn()}, which
must take the following arguments with these exact names:
\itemize{
\item \code{params}: trainable parameters of the model.
\item \code{state} (\emph{optional}): non-trainable state of the model. Can be omitted if
the model has no non-trainable state.
\item \code{rng} (\emph{optional}): a \code{jax.random.PRNGKey} instance. Can be omitted if the
model does not need RNGs, neither during training nor during inference.
\item \code{inputs}: inputs to the model, a JAX array or a \code{PyTree} of arrays.
\item \code{training} (\emph{optional}): an argument specifying if we're in training mode
or inference mode, \code{TRUE} is passed in training mode. Can be omitted if
the model behaves the same in training mode and inference mode.
}

The \code{inputs} argument is mandatory. Inputs to the model must be provided via
a single argument. If the JAX model takes multiple inputs as separate
arguments, they must be combined into a single structure, for instance in a
\code{tuple()} or a \code{dict()}.
\subsection{Model weights initialization}{

The initialization of the \code{params} and \code{state} of the model can be handled
by this layer, in which case the \code{init_fn()} argument must be provided. This
allows the model to be initialized dynamically with the right shape.
Alternatively, and if the shape is known, the \code{params} argument and
optionally the \code{state} argument can be used to create an already initialized
model.

The \code{init_fn()} function, if provided, must take the following arguments with
these exact names:
\itemize{
\item \code{rng}: a \code{jax.random.PRNGKey} instance.
\item \code{inputs}: a JAX array or a \code{PyTree} of arrays with placeholder values to
provide the shape of the inputs.
\item \code{training} (\emph{optional}): an argument specifying if we're in training mode
or inference mode. \code{True} is always passed to \code{init_fn}. Can be omitted
regardless of whether \code{call_fn} has a \code{training} argument.
}
}

\subsection{Models with non-trainable state}{

For JAX models that have non-trainable state:
\itemize{
\item \code{call_fn()} must have a \code{state} argument
\item \code{call_fn()} must return a \code{tuple()} containing the outputs of the model and
the new non-trainable state of the model
\item \code{init_fn()} must return a \code{tuple()} containing the initial trainable params of
the model and the initial non-trainable state of the model.
}

This code shows a possible combination of \code{call_fn()} and \code{init_fn()} signatures
for a model with non-trainable state. In this example, the model has a
\code{training} argument and an \code{rng} argument in \code{call_fn()}.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{stateful_call <- function(params, state, rng, inputs, training) \{
  outputs <- ....
  new_state <- ....
  tuple(outputs, new_state)
\}

stateful_init <- function(rng, inputs) \{
  initial_params <- ....
  initial_state <- ....
  tuple(initial_params, initial_state)
\}
}\if{html}{\out{</div>}}
}

\subsection{Models without non-trainable state}{

For JAX models with no non-trainable state:
\itemize{
\item \code{call_fn()} must not have a \code{state} argument
\item \code{call_fn()} must return only the outputs of the model
\item \code{init_fn()} must return only the initial trainable params of the model.
}

This code shows a possible combination of \code{call_fn()} and \code{init_fn()} signatures
for a model without non-trainable state. In this example, the model does not
have a \code{training} argument and does not have an \code{rng} argument in \code{call_fn()}.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{stateful_call <- function(pparams, inputs) \{
  outputs <- ....
  outputs
\}

stateful_init <- function(rng, inputs) \{
  initial_params <- ....
  initial_params
\}
}\if{html}{\out{</div>}}
}

\subsection{Conforming to the required signature}{

If a model has a different signature than the one required by \code{JaxLayer},
one can easily write a wrapper method to adapt the arguments. This example
shows a model that has multiple inputs as separate arguments, expects
multiple RNGs in a \code{dict}, and has a \code{deterministic} argument with the
opposite meaning of \code{training}. To conform, the inputs are combined in a
single structure using a \code{tuple}, the RNG is split and used the populate the
expected \code{dict}, and the Boolean flag is negated:

\if{html}{\out{<div class="sourceCode r">}}\preformatted{jax <- import("jax")
my_model_fn <- function(params, rngs, input1, input2, deterministic) \{
  ....
  if (!deterministic) \{
    dropout_rng <- rngs$dropout
    keep <- jax$random$bernoulli(dropout_rng, dropout_rate, x$shape)
    x <- jax$numpy$where(keep, x / dropout_rate, 0)
    ....
  \}
  ....
  return(outputs)
\}

my_model_wrapper_fn <- function(params, rng, inputs, training) \{
  c(input1, input2) \%<-\% inputs
  c(rng1, rng2) \%<-\% jax$random$split(rng)
  rngs <-  list(dropout = rng1, preprocessing = rng2)
  deterministic <-  !training
  my_model_fn(params, rngs, input1, input2, deterministic)
\}

keras_layer <- layer_jax_model_wrapper(call_fn = my_model_wrapper_fn,
                                       params = initial_params)
}\if{html}{\out{</div>}}
}

\subsection{Usage with Haiku modules}{

\code{JaxLayer} enables the use of \href{https://dm-haiku.readthedocs.io}{Haiku}
components in the form of
\href{https://dm-haiku.readthedocs.io/en/latest/api.html#module}{\code{haiku.Module}}.
This is achieved by transforming the module per the Haiku pattern and then
passing \code{module.apply} in the \code{call_fn} parameter and \code{module.init} in the
\code{init_fn} parameter if needed.

If the model has non-trainable state, it should be transformed with
\href{https://dm-haiku.readthedocs.io/en/latest/api.html#haiku.transform_with_state}{\code{haiku.transform_with_state}}.
If the model has no non-trainable state, it should be transformed with
\href{https://dm-haiku.readthedocs.io/en/latest/api.html#haiku.transform}{\code{haiku.transform}}.
Additionally, and optionally, if the module does not use RNGs in "apply", it
can be transformed with
\href{https://dm-haiku.readthedocs.io/en/latest/api.html#without-apply-rng}{\code{haiku.without_apply_rng}}.

The following example shows how to create a \code{JaxLayer} from a Haiku module
that uses random number generators via \code{hk.next_rng_key()} and takes a
training positional argument:

\if{html}{\out{<div class="sourceCode r">}}\preformatted{# reticulate::py_install("haiku", "r-keras")
hk <- import("haiku")
MyHaikuModule(hk$Module) \\\%py_class\\\% \{

  `__call__` <- \\(self, x, training) \{
    x <- hk$Conv2D(32L, tuple(3L, 3L))(x)
    x <- jax$nn$relu(x)
    x <- hk$AvgPool(tuple(1L, 2L, 2L, 1L),
                    tuple(1L, 2L, 2L, 1L), "VALID")(x)
    x <- hk$Flatten()(x)
    x <- hk$Linear(200L)(x)
    if (training)
      x <- hk$dropout(rng = hk$next_rng_key(), rate = 0.3, x = x)
    x <- jax$nn$relu(x)
    x <- hk$Linear(10L)(x)
    x <- jax$nn$softmax(x)
    x
  \}

\}

my_haiku_module_fn <- function(inputs, training) \{
  module <- MyHaikuModule()
  module(inputs, training)
\}

transformed_module <- hk$transform(my_haiku_module_fn)

keras_layer <-
  layer_jax_model_wrapper(call_fn = transformed_module$apply,
                          init_fn = transformed_module$init)
}\if{html}{\out{</div>}}
}
}

\seealso{
Other wrapping layers: \cr
\code{\link{layer_flax_module_wrapper}()} \cr
\code{\link{layer_torch_module_wrapper}()} \cr

Other layers: \cr
\code{\link{Layer}()} \cr
\code{\link{layer_activation}()} \cr
\code{\link{layer_activation_elu}()} \cr
\code{\link{layer_activation_leaky_relu}()} \cr
\code{\link{layer_activation_parametric_relu}()} \cr
\code{\link{layer_activation_relu}()} \cr
\code{\link{layer_activation_softmax}()} \cr
\code{\link{layer_activity_regularization}()} \cr
\code{\link{layer_add}()} \cr
\code{\link{layer_additive_attention}()} \cr
\code{\link{layer_alpha_dropout}()} \cr
\code{\link{layer_attention}()} \cr
\code{\link{layer_aug_mix}()} \cr
\code{\link{layer_auto_contrast}()} \cr
\code{\link{layer_average}()} \cr
\code{\link{layer_average_pooling_1d}()} \cr
\code{\link{layer_average_pooling_2d}()} \cr
\code{\link{layer_average_pooling_3d}()} \cr
\code{\link{layer_batch_normalization}()} \cr
\code{\link{layer_bidirectional}()} \cr
\code{\link{layer_category_encoding}()} \cr
\code{\link{layer_center_crop}()} \cr
\code{\link{layer_concatenate}()} \cr
\code{\link{layer_conv_1d}()} \cr
\code{\link{layer_conv_1d_transpose}()} \cr
\code{\link{layer_conv_2d}()} \cr
\code{\link{layer_conv_2d_transpose}()} \cr
\code{\link{layer_conv_3d}()} \cr
\code{\link{layer_conv_3d_transpose}()} \cr
\code{\link{layer_conv_lstm_1d}()} \cr
\code{\link{layer_conv_lstm_2d}()} \cr
\code{\link{layer_conv_lstm_3d}()} \cr
\code{\link{layer_cropping_1d}()} \cr
\code{\link{layer_cropping_2d}()} \cr
\code{\link{layer_cropping_3d}()} \cr
\code{\link{layer_cut_mix}()} \cr
\code{\link{layer_dense}()} \cr
\code{\link{layer_depthwise_conv_1d}()} \cr
\code{\link{layer_depthwise_conv_2d}()} \cr
\code{\link{layer_discretization}()} \cr
\code{\link{layer_dot}()} \cr
\code{\link{layer_dropout}()} \cr
\code{\link{layer_einsum_dense}()} \cr
\code{\link{layer_embedding}()} \cr
\code{\link{layer_equalization}()} \cr
\code{\link{layer_feature_space}()} \cr
\code{\link{layer_flatten}()} \cr
\code{\link{layer_flax_module_wrapper}()} \cr
\code{\link{layer_gaussian_dropout}()} \cr
\code{\link{layer_gaussian_noise}()} \cr
\code{\link{layer_global_average_pooling_1d}()} \cr
\code{\link{layer_global_average_pooling_2d}()} \cr
\code{\link{layer_global_average_pooling_3d}()} \cr
\code{\link{layer_global_max_pooling_1d}()} \cr
\code{\link{layer_global_max_pooling_2d}()} \cr
\code{\link{layer_global_max_pooling_3d}()} \cr
\code{\link{layer_group_normalization}()} \cr
\code{\link{layer_group_query_attention}()} \cr
\code{\link{layer_gru}()} \cr
\code{\link{layer_hashed_crossing}()} \cr
\code{\link{layer_hashing}()} \cr
\code{\link{layer_identity}()} \cr
\code{\link{layer_integer_lookup}()} \cr
\code{\link{layer_lambda}()} \cr
\code{\link{layer_layer_normalization}()} \cr
\code{\link{layer_lstm}()} \cr
\code{\link{layer_masking}()} \cr
\code{\link{layer_max_num_bounding_boxes}()} \cr
\code{\link{layer_max_pooling_1d}()} \cr
\code{\link{layer_max_pooling_2d}()} \cr
\code{\link{layer_max_pooling_3d}()} \cr
\code{\link{layer_maximum}()} \cr
\code{\link{layer_mel_spectrogram}()} \cr
\code{\link{layer_minimum}()} \cr
\code{\link{layer_mix_up}()} \cr
\code{\link{layer_multi_head_attention}()} \cr
\code{\link{layer_multiply}()} \cr
\code{\link{layer_normalization}()} \cr
\code{\link{layer_permute}()} \cr
\code{\link{layer_rand_augment}()} \cr
\code{\link{layer_random_brightness}()} \cr
\code{\link{layer_random_color_degeneration}()} \cr
\code{\link{layer_random_color_jitter}()} \cr
\code{\link{layer_random_contrast}()} \cr
\code{\link{layer_random_crop}()} \cr
\code{\link{layer_random_erasing}()} \cr
\code{\link{layer_random_flip}()} \cr
\code{\link{layer_random_gaussian_blur}()} \cr
\code{\link{layer_random_grayscale}()} \cr
\code{\link{layer_random_hue}()} \cr
\code{\link{layer_random_invert}()} \cr
\code{\link{layer_random_perspective}()} \cr
\code{\link{layer_random_posterization}()} \cr
\code{\link{layer_random_rotation}()} \cr
\code{\link{layer_random_saturation}()} \cr
\code{\link{layer_random_sharpness}()} \cr
\code{\link{layer_random_shear}()} \cr
\code{\link{layer_random_translation}()} \cr
\code{\link{layer_random_zoom}()} \cr
\code{\link{layer_repeat_vector}()} \cr
\code{\link{layer_rescaling}()} \cr
\code{\link{layer_reshape}()} \cr
\code{\link{layer_resizing}()} \cr
\code{\link{layer_rms_normalization}()} \cr
\code{\link{layer_rnn}()} \cr
\code{\link{layer_separable_conv_1d}()} \cr
\code{\link{layer_separable_conv_2d}()} \cr
\code{\link{layer_simple_rnn}()} \cr
\code{\link{layer_solarization}()} \cr
\code{\link{layer_spatial_dropout_1d}()} \cr
\code{\link{layer_spatial_dropout_2d}()} \cr
\code{\link{layer_spatial_dropout_3d}()} \cr
\code{\link{layer_spectral_normalization}()} \cr
\code{\link{layer_stft_spectrogram}()} \cr
\code{\link{layer_string_lookup}()} \cr
\code{\link{layer_subtract}()} \cr
\code{\link{layer_text_vectorization}()} \cr
\code{\link{layer_tfsm}()} \cr
\code{\link{layer_time_distributed}()} \cr
\code{\link{layer_torch_module_wrapper}()} \cr
\code{\link{layer_unit_normalization}()} \cr
\code{\link{layer_upsampling_1d}()} \cr
\code{\link{layer_upsampling_2d}()} \cr
\code{\link{layer_upsampling_3d}()} \cr
\code{\link{layer_zero_padding_1d}()} \cr
\code{\link{layer_zero_padding_2d}()} \cr
\code{\link{layer_zero_padding_3d}()} \cr
\code{\link{rnn_cell_gru}()} \cr
\code{\link{rnn_cell_lstm}()} \cr
\code{\link{rnn_cell_simple}()} \cr
\code{\link{rnn_cells_stack}()} \cr
}
\concept{layers}
\concept{wrapping layers}

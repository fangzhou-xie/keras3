% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/layers-preprocessing.R
\name{layer_stft_spectrogram}
\alias{layer_stft_spectrogram}
\title{Layer to compute the Short-Time Fourier Transform (STFT) on a 1D signal.}
\usage{
layer_stft_spectrogram(
  object,
  mode = "log",
  frame_length = 256L,
  frame_step = NULL,
  fft_length = NULL,
  window = "hann",
  periodic = FALSE,
  scaling = "density",
  padding = "valid",
  expand_dims = FALSE,
  data_format = NULL,
  ...
)
}
\arguments{
\item{object}{Object to compose the layer with. A tensor, array, or sequential model.}

\item{mode}{String, the output type of the spectrogram. Can be one of
\code{"log"}, \verb{"magnitude}", \code{"psd"}, \verb{"real}", \verb{"imag}", \verb{"angle}",
\verb{"stft}". Defaults to \verb{"log}".}

\item{frame_length}{Integer, The length of each frame (window) for STFT in
samples. Defaults to \code{256}.}

\item{frame_step}{Integer, the step size (hop length) between
consecutive frames. If not provided, defaults to half the
frame_length. Defaults to \code{frame_length \%/\% 2}.}

\item{fft_length}{Integer, the size of frequency bins used in the Fast-Fourier
Transform (FFT) to apply to each frame. Should be greater than or
equal to \code{frame_length}.  Recommended to be a power of two. Defaults
to the smallest power of two that is greater than or equal
to \code{frame_length}.}

\item{window}{(String or array_like), the windowing function to apply to each
frame. Can be \verb{"hann}" (default), \verb{"hamming}", or a custom window
provided as an array_like.}

\item{periodic}{Boolean, if \code{TRUE}, the window function will be treated as
periodic. Defaults to \code{FALSE}.}

\item{scaling}{String, type of scaling applied to the window. Can be
\verb{"density}", \verb{"spectrum}", or None. Default is \verb{"density}".}

\item{padding}{String, padding strategy. Can be \verb{"valid}" or \verb{"same}".
Defaults to \code{"valid"}.}

\item{expand_dims}{Boolean, if \code{TRUE}, will expand the output into spectrograms
into two dimensions to be compatible with image models.
Defaults to \code{FALSE}.}

\item{data_format}{String, either \code{"channels_last"} or \code{"channels_first"}.
The ordering of the dimensions in the inputs. \code{"channels_last"}
corresponds to inputs with shape \verb{(batch, height, width, channels)}
while \code{"channels_first"} corresponds to inputs with shape
\verb{(batch, channels, height, weight)}. Defaults to \code{"channels_last"}.}

\item{...}{For forward/backward compatability.}
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
A layer that computes Spectrograms of the input signal to produce
a spectrogram. This layers by
The layer computes Spectrograms based on Short-Time Fourier Transform (STFT)
by utilizing convolution
kernels, which allows parallelization on GPUs and trainable kernels for
fine-tuning support. This layer allows different modes of output
(e.g., log-scaled magnitude, phase, power spectral density, etc.) and
provides flexibility in windowing, padding, and scaling options for the
STFT calculation.
}
\section{Examples}{
Apply it as a non-trainable preprocessing layer on 3 audio tracks of
1 channel, 10 seconds and sampled at 16 kHz.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{layer <- layer_stft_spectrogram(
  mode = 'log',
  frame_length = 256,
  frame_step = 128, # 50\% overlap
  fft_length = 512,
  window = "hann",
  padding = "valid",
  trainable = FALSE # non-trainable, preprocessing only)
)
random_uniform(shape=c(3, 160000, 1)) |> layer() |> op_shape()
}\if{html}{\out{</div>}}

\if{html}{\out{<div class="sourceCode">}}\preformatted{## shape(3, 1249, 257)

}\if{html}{\out{</div>}}

Apply it as a trainable processing layer on 3 stereo audio tracks of
2 channels, 10 seconds and sampled at 16 kHz. This is initialized as the
non-trainable layer, but then can be trained jointly within a model.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{layer <- layer_stft_spectrogram(
  mode = 'log',
  frame_length = 256,
  frame_step = 128,   # 50\% overlap
  fft_length = 512,
  window = "hamming", # hamming windowing function
  padding = "same",   # padding to preserve the time dimension
  trainable = TRUE,   # trainable, this is the default in keras
)
random_uniform(shape=c(3, 160000, 2)) |> layer() |> op_shape()
}\if{html}{\out{</div>}}

\if{html}{\out{<div class="sourceCode">}}\preformatted{## shape(3, 1250, 514)

}\if{html}{\out{</div>}}

Similar to the last example, but add an extra dimension so the output is
an image to be used with image models. We apply this here on a signal of
3 input channels to output an image tensor, hence is directly applicable
with an image model.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{layer <- layer_stft_spectrogram(
  mode = 'log',
  frame_length = 256,
  frame_step = 128,
  fft_length = 512,
  padding = "same",
  expand_dims = TRUE  # this adds the extra dimension
)
random_uniform(shape=c(3, 160000, 3)) |> layer() |> op_shape()
}\if{html}{\out{</div>}}

\if{html}{\out{<div class="sourceCode">}}\preformatted{## shape(3, 1250, 257, 3)

}\if{html}{\out{</div>}}
}

\section{Raises}{
ValueError: If an invalid value is provided for \verb{"mode}", \verb{"scaling}",
\verb{"padding}", or other input arguments.
TypeError: If the input data type is not one of \verb{"float16}",
\verb{"float32}", or \verb{"float64}".
}

\section{Input Shape}{
A 3D tensor of shape \verb{(batch_size, time_length, input_channels)}, if
\code{data_format=="channels_last"}, and of shape
\verb{(batch_size, input_channels, time_length)} if
\code{data_format=="channels_first"}, where \code{time_length} is the length of
the input signal, and \code{input_channels} is the number of input channels.
The same kernels are applied to each channel independently.
}

\section{Output Shape}{
If \code{data_format=="channels_first" && !expand_dims}, a 3D tensor:
\verb{(batch_size, input_channels * freq_channels, new_time_length)}
If \code{data_format=="channels_last" && !expand_dims}, a 3D tensor:
\verb{(batch_size, new_time_length, input_channels * freq_channels)}
If \code{data_format=="channels_first" && expand_dims}, a 4D tensor:
\verb{(batch_size, input_channels, new_time_length, freq_channels)}
If \code{data_format=="channels_last" && expand_dims}, a 4D tensor:
\verb{(batch_size, new_time_length, freq_channels, input_channels)}

where \code{new_time_length} depends on the padding, and \code{freq_channels} is
the number of FFT bins \code{(fft_length \%/\% 2 + 1)}.
}

\seealso{
Other audio preprocessing layers: \cr
\code{\link{layer_mel_spectrogram}()} \cr

Other preprocessing layers: \cr
\code{\link{layer_aug_mix}()} \cr
\code{\link{layer_auto_contrast}()} \cr
\code{\link{layer_category_encoding}()} \cr
\code{\link{layer_center_crop}()} \cr
\code{\link{layer_cut_mix}()} \cr
\code{\link{layer_discretization}()} \cr
\code{\link{layer_equalization}()} \cr
\code{\link{layer_feature_space}()} \cr
\code{\link{layer_hashed_crossing}()} \cr
\code{\link{layer_hashing}()} \cr
\code{\link{layer_integer_lookup}()} \cr
\code{\link{layer_max_num_bounding_boxes}()} \cr
\code{\link{layer_mel_spectrogram}()} \cr
\code{\link{layer_mix_up}()} \cr
\code{\link{layer_normalization}()} \cr
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
\code{\link{layer_rescaling}()} \cr
\code{\link{layer_resizing}()} \cr
\code{\link{layer_solarization}()} \cr
\code{\link{layer_string_lookup}()} \cr
\code{\link{layer_text_vectorization}()} \cr

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
\code{\link{layer_jax_model_wrapper}()} \cr
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
\concept{audio preprocessing layers}
\concept{layers}
\concept{preprocessing layers}

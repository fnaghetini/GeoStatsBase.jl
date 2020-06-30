# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LearnedModel(model, θ)

An object that stores `model` together with learned parameters `θ`.
"""
struct LearnedModel
  model
  θ
end

"""
    learn(task, sdata, model)

Learn the `task` with `sdata` using a learning `model`.
"""
function learn(task::AbstractLearningTask, sdata::AbstractData, model)
  if issupervised(task)
    X = view(sdata, collect(features(task)))
    y = sdata[label(task)]
    θ, _, __ = MI.fit(model, 0, X, y)
  else
    X = view(sdata, collect(features(task)))
    θ, _, __ = MI.fit(model, 0, X)
  end

  LearnedModel(model, θ)
end

"""
    perform(task, sdata, lmodel)

Perform the `task` with `sdata` using a *learned* `lmodel`.
"""
function perform(task::AbstractLearningTask, sdata::AbstractData, lmodel::LearnedModel)
  # unpack model and learned parameters
  model, θ = lmodel.model, lmodel.θ

  # apply model to the data
  X = view(sdata, collect(features(task)))
  ŷ = MI.predict(model, θ, X)

  # post-process result
  var = outputvars(task)[1]
  if issupervised(task)
    result = isprobabilistic(model) ? mode.(ŷ) : ŷ
  else
    result = ŷ
  end

  DataFrame([var=>result])
end

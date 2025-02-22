@testset "Statistics" begin
  @testset "Ensemble" begin
    grid = CartesianGrid(3,3)
    reals = Dict(:value => [i*ones(nelements(grid)) for i in 1:3])
    ensemble = Ensemble(grid, reals)

    # mean
    mean2D = mean(ensemble)
    @test mean2D[:value] == 2.0*ones(nelements(mean2D))
    @test domain(mean2D) == ensemble.domain

    # variance
    var2D = var(ensemble)
    @test var2D[:value] == 1.0*ones(nelements(var2D))
    @test domain(var2D) == ensemble.domain

    # quantile (scalar)
    p = 0.5
    quant2D = quantile(ensemble, p)
    @test quant2D[:value] == 2.0*ones(nelements(quant2D))
    @test domain(quant2D) == ensemble.domain

    # quantile (vector)
    ps = [0.0, 0.5, 1.0]
    quants2D = quantile(ensemble, ps)
    @test quants2D[2][:value] == quant2D[:value]
  end

  @testset "HalfSampleMode" begin
    d = LogNormal(0,1)
    rs = rand(d,1000)
    @test GeoStatsBase.hsm_mode([1,2,2,3]) == 2.0
    @test GeoStatsBase.hsm_mode([1,2,2,3,5]) == 2.0
    @test GeoStatsBase.hsm_mode(rs) < mean(rs)
    @test GeoStatsBase.hsm_mode(rs) < median(rs)
    d = MixtureModel([Normal(), Normal(3, 0.2)], [0.7, 0.3])
    rs = rand(d, 1000)
    @test GeoStatsBase.hsm_mode(rs) < mean(rs)
    @test GeoStatsBase.hsm_mode(rs) < median(rs)
  end

  @testset "Data" begin
    # load data with bias towards large values (gold mine)
    sdata = georef(CSV.File(joinpath(datadir,"clustered.csv")), (:x,:y))

    # spatial mean
    μn = mean(sdata[:Au])
    μs = mean(sdata, :Au)
    @test abs(μn - 0.5) > abs(μs - 0.5)
    @test mean(sdata)[:Au] ≈ μs

    # spatial variance
    σn = var(sdata[:Au])
    σs = var(sdata, :Au)
    @test isapprox(σn, σs, atol=1e-2)
    @test var(sdata)[:Au] ≈ σs

    # spatial quantile
    qn = quantile(sdata[:Au], 0.5)
    qs = quantile(sdata, :Au, 0.5)
    @test qn ≥ qs
    @test quantile(sdata, 0.5)[:Au] ≈ qs
  end
end

defmodule AppClustering do
  @moduledoc false

  @doc """
  Clusterize the apps

  ## Examples

      iex> AppClustering.clusterize("./assets/classifier-sample.json")

      or with jaccard similarity index

      iex> AppClustering.clusterize("./assets/classifier-sample.json", 0.3)
  """
  @spec clusterize(file :: String.t(), threshold :: number()) :: list()
  def clusterize(file, threshold \\ 0.5) do
    {:ok, data} = File.read(file)
    sample_json = Jsonrs.decode!(data)

    optimized_data = optimize_data(sample_json)

    {clusters, _} =
      Enum.reduce_while(optimized_data, {[], optimized_data}, fn _,
                                                                 {clusters,
                                                                  [
                                                                    {current_key, current_paths}
                                                                    | rest
                                                                  ]} ->
        {index, clusters} =
          case Enum.find_index(clusters, &(current_key in &1)) do
            nil -> {-1, clusters ++ [[current_key]]}
            index -> {index, clusters}
          end

        case Enum.reduce(rest, {clusters, rest}, fn {compare_key, compare_paths},
                                                    {acc_clusters, acc_rest} ->
               similarity = jaccard_similarity(current_paths, compare_paths)

               if similarity > threshold,
                 do:
                   {List.update_at(acc_clusters, index, &(&1 ++ [compare_key])),
                    List.keydelete(acc_rest, compare_key, 0)},
                 else: {acc_clusters, acc_rest}
             end) do
          {_, []} = acc -> {:halt, acc}
          acc -> {:cont, acc}
        end
      end)

    clusters
  end

  @ignore_paths_with_ending ~w"Frameworks/ SC_Info/ _CodeSignature/ META-INF/"

  # Optimizing data by removing files, common iOS config, app name etc.
  defp optimize_data(json) do
    Enum.map(json, fn {id, [_meta, _payload, app | rest]} ->
      paths =
        rest
        |> Enum.map(&String.replace(&1, app, ""))
        |> Enum.filter(fn path ->
          String.ends_with?(path, "/") &&
            !String.ends_with?(path, @ignore_paths_with_ending)
        end)

      {id, paths}
    end)
  end

  # https://en.wikipedia.org/wiki/Jaccard_index
  defp jaccard_similarity(paths1, paths2) do
    set1 = MapSet.new(paths1)
    set2 = MapSet.new(paths2)

    intersection = MapSet.size(MapSet.intersection(set1, set2))
    union = MapSet.size(MapSet.union(set1, set2))

    intersection / union
  end
end

# E8_Simplifier.py — Ribosome GNN for Topological Efficiency
import torch
import torch.nn.functional as F
from torch_geometric.nn import GATConv

class E8Simplifier(torch.nn.Module):
    def __init__(self, in_channels: int = 8, out_channels: int = 1):
        super(E8Simplifier, self).__init__()
        # 8 channels to match the 8 dimensions of the E8 Lattice
        self.conv1 = GATConv(in_channels, 16, heads=8, dropout=0.1)
        self.conv2 = GATConv(16 * 8, out_channels, heads=1, concat=False, dropout=0.1)

    def forward(self, x, edge_index):
        # x: Node features (8D coordinates in the E8 lattice)
        # edge_index: Graph connectivity
        x = F.elu(self.conv1(x, edge_index))
        # Output is the "Importance Weight" for each node/edge
        x = self.conv2(x, edge_index)
        return torch.sigmoid(x)

    def prune_to_soliton_highways(self, weights, edge_index, threshold=0.75):
        """Prunes edges below the significance threshold to optimize routing"""
        mask = weights > threshold
        return edge_index[:, mask.view(-1)]

require 'rails_helper'

RSpec.describe Node, type: :model do
  let!(:user1) { create(:user) }
  describe "#set_file_or_folder" do
    context "ファイルを作成" do
      let!(:node1) { create(:node, user:user1, parent_node_id:user1.root_node.id, name:nil) }
      it "添付ファイル名が name になる" do
        expect(node1.name).to eq 'file1.txt'
      end
    end
    context "フォルダを作成" do
      let!(:node1) { create(:node, user:user1, parent_node_id:user1.root_node.id, name:"folder1", file:nil, is_folder:false) }
      it "is_folder が真になる" do
        expect(node1.is_folder).to eq true
      end
    end
  end

  describe "#create_copy" do
    context "ファイルをコピー" do
      let!(:node1) { create(:node, user:user1, parent_node_id:user1.root_node.id, name:nil) }
      let(:node2) { node1.create_copy; Node.last }
      it "ファイル名は同じ" do
        expect(node2.name).to eq node1.name
      end
      it "share_path は異なる" do
        expect(node2.share_path).not_to eq node1.share_path
      end
      it "保存ファイルのパスも異なる" do
        expect(node2.file.current_path).not_to eq node1.file.current_path
      end
    end
  end

  describe "#get_path & #get_path_string" do
    context "フォルダ作成済み" do
      let!(:folder1) { create(:node, user:user1, parent_node_id:user1.root_node.id, name:"folder1", file:nil)}
      let!(:folder2) { create(:node, user:user1, parent_node_id:folder1.id, name:"folder2", file:nil)}
      let!(:folder3) { create(:node, user:user1, parent_node_id:folder1.id, name:"folder3", file:nil)}
      let!(:folder4) { create(:node, user:user1, parent_node_id:folder2.id, name:"folder4", file:nil)}
      let!(:file1) { create(:node, user:user1, parent_node_id:user1.root_node.id )}
      let!(:file2) { create(:node, user:user1, parent_node_id:folder2.id )}
      let!(:file3) { create(:node, user:user1, parent_node_id:folder4.id )}
      it { expect(folder1.get_path).to eq [user1.root_node, folder1] }
      it { expect(folder2.get_path).to eq [user1.root_node, folder1, folder2] }
      it { expect(file1.get_path).to eq [user1.root_node, file1] }
      it { expect(file2.get_path).to eq [user1.root_node, folder1, folder2, file2] }
      it { expect(file3.get_path).to eq [user1.root_node, folder1, folder2, folder4, file3] }
      it { expect(file2.get_path_string).to eq 'root/folder1/folder2/file1.txt' }
    end
  end

  describe "#get_folder_tree" do
    context "フォルダ作成済み" do
      let!(:folder1) { create(:node, user:user1, parent_node_id:user1.root_node.id, name:"folder1", file:nil)}
      let!(:folder2) { create(:node, user:user1, parent_node_id:folder1.id, name:"folder2", file:nil)}
      let!(:folder3) { create(:node, user:user1, parent_node_id:folder1.id, name:"folder3", file:nil)}
      let!(:folder4) { create(:node, user:user1, parent_node_id:folder2.id, name:"folder4", file:nil)}
      it { expect(Node.get_folder_tree(user1)).to eq(
          {
            user1.root_node => {
              folder1 => {
                folder2 => {
                  folder4 => {}
                },
                folder3 => {}
              }
            }
          }
        )
      }
    end
  end

  describe "#can_access_share_node" do
    context "ユーザー&フォルダ作成済み" do
      let!(:user2) { create(:user) }
      let!(:user3) { create(:user) }
      let!(:folder1) { create(:node, user:user1, parent_node_id:user1.root_node.id, name:"folder1", file:nil)}
      let!(:folder2) { create(:node, user:user1, parent_node_id:folder1.id, name:"folder2", file:nil)}
      let!(:folder3) { create(:node, user:user1, parent_node_id:folder1.id, name:"folder3", file:nil)}
      let!(:folder4) { create(:node, user:user1, parent_node_id:folder2.id, name:"folder4", file:nil)}
      let!(:file1) { create(:node, user:user1, parent_node_id:user1.root_node.id )}
      let!(:file2) { create(:node, user:user1, parent_node_id:folder2.id )}
      let!(:file3) { create(:node, user:user1, parent_node_id:folder4.id )}

      it "非公開" do
        folder2.update(share_mode: 0)
        expect(Node.can_access_share_node(nil, folder2, nil)).to eq false
        expect(Node.can_access_share_node(user2, folder2, nil)).to eq false
        expect(Node.can_access_share_node(user3, folder2, nil)).to eq false
        expect(Node.can_access_share_node(nil, folder2, file2)).to eq false
        expect(Node.can_access_share_node(user2, folder2, file2)).to eq false
        expect(Node.can_access_share_node(user3, folder2, file2)).to eq false
      end

      it "全体公開" do
        folder2.update(share_mode: 1)
        expect(Node.can_access_share_node(nil, folder2, nil)).to eq true
        expect(Node.can_access_share_node(user2, folder2, nil)).to eq true
        expect(Node.can_access_share_node(user3, folder2, nil)).to eq true
        expect(Node.can_access_share_node(nil, folder2, file2)).to eq true
        expect(Node.can_access_share_node(user2, folder2, file2)).to eq true
        expect(Node.can_access_share_node(user3, folder2, file2)).to eq true
      end

      it "限定公開" do
        folder2.update(share_mode: 2)
        create(:share_user, user:user2, node:folder2)
        expect(Node.can_access_share_node(user2, folder2, nil)).to eq true
        expect(Node.can_access_share_node(user2, folder2, file2)).to eq true
        expect(Node.can_access_share_node(user2, folder2, folder4)).to eq true
        expect(Node.can_access_share_node(user2, folder2, file3)).to eq true
        expect(Node.can_access_share_node(user2, folder3, nil)).to eq false
        expect(Node.can_access_share_node(user2, folder1, nil)).to eq false
        expect(Node.can_access_share_node(user3, folder2, nil)).to eq false
      end
    end
  end
end
